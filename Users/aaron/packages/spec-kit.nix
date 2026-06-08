{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "spec-kit";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "github";
    repo = "spec-kit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cyCmazcqjeGg4Qz6kx2MKxrgyduuP7wj9pV4De/M060=";
  };

  pyproject = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    typer
    click
    rich
    platformdirs
    readchar
    pyyaml
    packaging
    pathspec
    json5
  ];

  pythonImportsCheck = [
    "specify_cli"
  ];

  meta = {
    description = "Bootstrap your projects for Spec-Driven Development (SDD)";
    homepage = "https://github.com/github/spec-kit";
    changelog = "https://github.com/github/spec-kit/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "specify";
  };
})
