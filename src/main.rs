use std::{
    collections::HashMap,
    fs::{self, OpenOptions},
    io::{ErrorKind, Read, Write},
    mem,
    ops::AddAssign,
    path::Path,
};

use anyhow::{anyhow, Context as _, Error, Result};
use just_fetch::{Fetcher, Resource};
use log::{debug, info};
use serde::{Deserialize, Serialize};
use structopt::StructOpt;
use tar::{Archive, EntryType};
use tera::{Context, Tera};

#[derive(StructOpt)]
struct Opt {
    /// Don't resolve imports from the standard configuration file.
    #[structopt(short, long)]
    pure: bool,
    /// Add another TOML file/url configuration file that contains a
    /// list of scaffolds to import from. Any newer imports take
    /// precedence over any older ones, as well as any from the
    /// default config file.
    #[structopt(short, long, number_of_values = 1)]
    import: Vec<String>,
    /// Override files without a care in the world. Don't use this
    /// unless AT LEAST you have your files backed up into version
    /// control!
    #[structopt(long)]
    force: bool,
    /// The scaffold identifiers to select, where each identifier can
    /// either be a name to be resolved by an import, or a file/url.
    scaffolds: Vec<String>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
struct Config {
    imports: HashMap<String, Resource>,
}
impl Config {
    pub fn resolve(&mut self, location: Resource) -> Result<()> {
        let imports = mem::replace(&mut self.imports, HashMap::default());
        self.imports = imports
            .into_iter()
            .map(|(key, value)| {
                location
                    .clone()
                    .join(&value)
                    .map(|joined| (key, joined))
                    .map_err(Error::from)
            })
            .collect::<Result<HashMap<String, Resource>>>()?;
        Ok(())
    }
}
impl AddAssign for Config {
    fn add_assign(&mut self, other: Self) {
        self.imports.extend(other.imports);
    }
}

fn main() -> Result<()> {
    env_logger::init();
    let opts = Opt::from_args();

    let mut config = Config::default();
    if !opts.pure {
        let mut path =
            dirs::config_dir().ok_or_else(|| anyhow!("config directory could not be found"))?;
        path.push("scaff");
        path.push("config.toml");

        match fs::read_to_string(&path) {
            Ok(content) => {
                config = toml::from_str(&content).context("failed to parse config's toml")?;
                config
                    .resolve(Resource::PathBuf(path))
                    .context("failed to resolve config paths")?;
            },
            Err(ref err) if err.kind() == ErrorKind::NotFound => {},
            err @ Err(_) => {
                err.context("failed to read config file")?;
            },
        }
    }

    let mut fetcher = Fetcher::new();

    for import in &opts.import {
        let import = Resource::from(&**import);
        let mut stream = fetcher
            .open(import.clone())
            .context("failed to fetch remote import")?;
        let mut content = String::new();
        stream.read_to_string(&mut content)?;

        let mut current: Config =
            toml::from_str(&content).context("failed to parse import's toml")?;
        current
            .resolve(import)
            .context("failed to resolve config paths")?;
        config += current;
    }

    if opts.scaffolds.is_empty() {
        println!("Imported scaffolds:");
        let mut scaffolds: Vec<_> = config.imports.iter().collect();
        scaffolds.sort_unstable_by_key(|&(n, _)| n);
        for (name, resource) in &scaffolds {
            println!("- {} (points to {})", name, resource);
        }
        return Ok(());
    }

    for scaffold in &opts.scaffolds {
        let scaffold = config
            .imports
            .get(&*scaffold)
            .cloned()
            .unwrap_or_else(|| Resource::from(&**scaffold));
        println!("Fetching {}...", scaffold);

        let stream = fetcher.open(scaffold).context("failed to fetch scaffold")?;
        let mut tar = Archive::new(stream);

        let mut templates = Vec::new();

        for entry in tar.entries().context("failed to read tar entries")? {
            let mut entry = entry.context("failed to read tar entry")?;
            let path_str = String::from_utf8(entry.path_bytes().to_vec())
                .context("entry path is not valid utf-8")?;
            debug!("Extracting {:?}", path_str);

            match entry.header().entry_type() {
                EntryType::Regular | EntryType::Symlink => {
                    let mut content = String::new();
                    entry
                        .read_to_string(&mut content)
                        .context("failed to read entry content")?;

                    templates.push((path_str, content))
                },
                EntryType::Directory => {},
                kind => info!("Warning: Ignoring entry type {:?} of {:?}", kind, path_str),
            }
        }

        let mut tera = Tera::default();
        tera.add_raw_templates(templates.iter().map(|(p, c)| (&**p, &**c)).collect())
            .map_err(|err| anyhow!("{}", err))
            .context("failed to add templates to tera engine")?;

        let mut context = Context::new();
        {
            let current_dir = std::env::current_dir().context("failed to get current directory")?;
            let project = current_dir
                .file_name()
                .context("failed to get current directory's filename")?
                .to_str()
                .context("cwd's filename is not utf-8")?;
            context.insert("project", project);
        }
        {
            let config = git2::Config::open_default().context("failed to get git config")?;
            let name = config
                .get_string("user.name")
                .context("failed to get git username")?;
            context.insert("name", &name);
        }

        for (path_str, _) in &templates {
            let content = tera
                .render(&path_str, &context)
                .map_err(|err| anyhow!("{}", err))
                .context("failed to render template with tera engine")?;

            let path = Path::new(path_str);
            let mut components = path.components();

            // .all(...) will short-circut as soon as it finds
            // "scaff-out", leaving .as_path(...) with only the remaining,
            // relevant, parts below.
            if components
                .by_ref()
                .all(|part| part.as_os_str() != "scaff-out")
            {
                continue;
            }

            let dest = components.as_path();
            if let Some(parent) = dest.parent() {
                fs::create_dir_all(parent)?;
            }
            let file = OpenOptions::new()
                .create(true)
                .truncate(true)
                .create_new(!opts.force)
                .write(true)
                .open(dest);
            match file {
                Ok(mut file) => {
                    file.write_all(content.as_bytes())
                        .context("failed to write destination file")?;
                },
                Err(ref err) if err.kind() == ErrorKind::AlreadyExists => {
                    println!("Not overwriting: {}", dest.display());
                },
                err @ Err(_) => {
                    err.context("failed to open destination file")?;
                },
            }
        }
    }

    Ok(())
}
