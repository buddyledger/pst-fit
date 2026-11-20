# pst-fit

PSTricks macros for curve fitting. The package fits curves to:

- linear functions
- power functions
- the exp function
- log<sub>10</sub> and log<sub>e</sub> functions
- Recip
- Kings Law data
- Gaussian
- 4th order polynomial

The package is published on CTAN at
[graphics/pstricks/contrib/pst-fit](https://ctan.org/tex-archive/graphics/pstricks/contrib/pst-fit).
Documentation is in [doc/pst-fit-doc.pdf](doc/pst-fit-doc.pdf).

This file is for the GitHub repository only. The plain `README` is the one shipped to CTAN.

## Releasing to CTAN

The [CTAN upload](../../actions/workflows/ctan-upload.yml) workflow sends the package to CTAN on demand.
It never runs on its own; someone has to start it.

### Before a release

1. Bump `\fileversion` and `\filedate` in `tex/pst-fit.tex`. CTAN requires an update to have a different version from the one it already holds.
2. Update the date in `\ProvidesPackage` in `latex/pst-fit.sty` if the wrapper changed.
3. Add an entry to `Changes`.
4. Rebuild `doc/pst-fit-doc.pdf` if the documentation changed. CTAN rejects an archive without PDF documentation.
5. Commit and push to `main`.

### Running the workflow

From the GitHub website: open the **Actions** tab, choose **CTAN upload**, click **Run workflow**, pick a mode and fill in the optional fields.

From a terminal with the GitHub CLI:

```bash
gh workflow run ctan-upload.yml -f mode=validate
```

```bash
gh workflow run ctan-upload.yml -f mode=upload -f announcement="What changed in this release"
```

| Input | Meaning |
|---|---|
| `mode` | `validate` is a dry run: CTAN checks the archive and the fields, and stores nothing. `upload` validates first and submits only if validation is clean. |
| `announcement` | Optional text for the CTAN announcement mailing list. Leave empty for no announcement. |
| `note` | Optional private note to the CTAN upload managers. |

Run `validate` first, read the log, then run `upload`.

### What the workflow does

1. Reads the version from `\fileversion` in `tex/pst-fit.tex`.
2. Builds `pst-fit.zip` with `README`, `Changes`, `doc/`, `latex/` and `tex/` under a top-level `pst-fit/` folder.
3. Saves the zip as a downloadable artifact on the workflow run.
4. Posts the zip and the package fields to CTAN's submit API, and prints CTAN's messages in the log.

The run fails if CTAN reports any error, or if an upload is not confirmed with "Upload succeeded".

### After an upload

An upload is not published immediately. The CTAN upload managers review it by hand, and they reply to the uploader's email address. The new version appears on CTAN once they have installed it.

### Setup

The workflow needs two repository secrets (**Settings → Secrets and variables → Actions**):

| Secret | Value |
|---|---|
| `CTAN_UPLOADER` | Name of the person uploading |
| `CTAN_EMAIL` | Their email address |

To set or change them from a terminal (each command prompts for the value):

```bash
gh secret set CTAN_UPLOADER
```

```bash
gh secret set CTAN_EMAIL
```

The fixed package fields (author, licence, summary, description and CTAN path) are set in
[.github/workflows/ctan-upload.yml](.github/workflows/ctan-upload.yml).

## Licence

LaTeX Project Public License (LPPL).
