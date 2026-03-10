# MeteoGarden-Backend

We will follow a simple and reliable Git workflow to keep the codebase stable and make collaboration easier.

### Branches
- `main`: stable branch (release-ready). No direct pushes.
- `develop`: integration branch. Feature work is merged here via PR.
- `feature/<short-name>`: one branch per task/feature (e.g. `feature/authentication`).
- `fix/<short-name>`: bug fixes.
- `docs/<short-name>`: documentation updates.
- `chore/<short-name>`: maintenance/tooling/dependencies.

### Rules
- No direct pushes to `main` (and ideally none to `develop`).
- All changes go through a Pull Request (PR) into `develop`.
- At least 1 approval before merging.
- PR must pass automated checks (CI) before merging.

### Typical flow
Create a branch from `develop`:
```bash
git checkout develop
git pull
git checkout -b feature/<short-name>
```

Commit and push:
```bash
git add .
git commit -m "feat: <short message>"
git push -u origin feature/<short-name>
```

## Format code for CI/CD pipeline