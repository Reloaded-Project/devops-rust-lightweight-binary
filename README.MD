<div align="center">
  <a href="https://github.com/Reloaded-Project/rust-lightweight-binary" target="_blank">
    <img src="assets/reloaded-logo.png" alt="reloaded Logo" width="100"/>
  </a>

  <h1 align="center">Reloaded Rust Build C Library Workflow</h1>

  <p>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License">
    </a>
  </p>
</div>

This is a GitHub Action that can be used to build an optimized, lightweight binary (or C library)
from a Rust project.

This action is used to build binaries with the following properties:

- **Self-Built std**: Reduces binary size and improves optimizations.
- **Abort on Panic**: Reduces binary size. Can be disabled if needed.
- **Profile Guided Optimization (PGO)**: Improves performance by optimizing based on usage patterns.
- **Cross-Compilation**: Supports cross-compilation using `cross-rs`.
- **Nightly Rust**: Uses the nightly Rust toolchain for building and running.

It can be used to build both binaries and C libraries.

## Example Usage

As a single job/step of a workflow:

```yaml
build-cli-tool:
  strategy:
    matrix:
      include:
        - os: ubuntu-latest
          target: x86_64-unknown-linux-gnu
          use-pgo: true
          use-cross: false
        - os: ubuntu-latest
          target: i686-unknown-linux-gnu
          use-pgo: true
          use-cross: false
        - os: ubuntu-latest
          target: aarch64-unknown-linux-gnu
          use-pgo: false # no native runner
          use-cross: true
        - os: ubuntu-latest
          target: armv7-unknown-linux-gnueabihf
          use-pgo: false # no native runner
          use-cross: true
        - os: windows-latest
          target: x86_64-pc-windows-msvc
          use-pgo: true
          use-cross: false
        - os: windows-latest
          target: i686-pc-windows-msvc
          use-pgo: true
          use-cross: false
        - os: windows-latest 
          target: aarch64-pc-windows-msvc
          use-pgo: false # no native runner
          use-cross: false
        - os: macos-13 # x86
          target: x86_64-apple-darwin
          use-pgo: true
          use-cross: false
        - os: macos-14 # M1
          target: aarch64-apple-darwin
          use-pgo: true
          use-cross: false

  runs-on: ${{ matrix.os }}

  steps:
    - uses: actions/checkout@v4
      with:
        submodules: recursive

    - id: build-libs
      uses: Reloaded-Project/devops-rust-lightweight-binary@v1
      with:
        target: ${{ matrix.target }}
        use-pgo: ${{ matrix.use-pgo }}
        use-cross: ${{ matrix.use-cross }}
        rust-project_path: "tools/cli/"
        crate-name: "prs-rs-cli"
```

## Setup

To use this action in your own repository:

1. Create a new workflow file (e.g., `.github/workflows/build-c-library.yml`) in your repository.
2. Copy the example usage job from above into the new workflow file.
3. Customize the input parameters as needed for your project.

If you are building a C library, ensure your project's `Cargo.toml` file defines
`crate-type = ["cdylib", "staticlib"]`.

## Configuration

### Inputs

| Input                  | Required | Default          | Description                                                                            |
| ---------------------- | -------- | ---------------- | -------------------------------------------------------------------------------------- |
| `rust-project-path`    | No       | `.`              | Path to the Rust project                                                               |
| `pgo-project-path`     | No       | `.`              | Path to the Rust project used for gathering PGO data. Can be same or separate project. |
| `crate-name`           | Yes      |                  | Name of the Rust crate (used to determine file name)                                   |
| `target`               | Yes      |                  | The target platform for the Rust compiler                                              |
| `features`             | No       | `''`             | Comma-separated list of features to include in the build                               |
| `use-pgo`              | No       | `false`          | Use Profile-Guided Optimization [PGO] to build the library.                            |
| `pgo-benchmark-name`   | No       | `'my_benchmark'` | Benchmark name to use with PGO.                                                        |
| `use-cross`            | No       | `false`          | Use cross-rs for building. If false, use cargo.                                        |
| `additional-rustflags` | No       | `''`             | Additional RUSTFLAGS to pass to the Rust compiler                                      |
| `upload-artifacts`     | No       | `true`           | Upload the built artifacts as a GitHub Actions artifact                                |
| `abort-on-panic`       | No       | `true`           | Abort immediately on panic. If false, the default panic handler is used.               |

### Setting up Profile-Guided Optimization (PGO)

Profile-Guided Optimization works by compiling and executing a benchmark whose name and project
can be defined by `pgo-benchmark-name` and `pgo-project-path` respectively. So you should strive
to keep the benchmark as close to the final usage of your application as possible.

Then said profile is used to build the final version of your application.

Setting `use-pgo` should work for any target technically speaking, as the profiling data is collected
on the host machine. However, I personally am not sure if it's a valid use case to use PGO data
when cross compiling code to a different CPU architecture. I haven't ran into issues trying, but
just be careful.

## Examples

Find more examples in [the tests](./.github/workflows/test-rust-build-c-library-workflow.yml).

### Custom PGO Project Path

```yaml
- name: Build C Library
  uses: Reloaded-Project/devops-rust-build-c-library@v1
  with:
    rust-project-path: ./rust-project
    pgo-project-path: ./pgo-project
    crate-name: my-crate
    target: x86_64-unknown-linux-gnu
```

### Using cross-rs for Building

```yaml
- name: Build C Library
  uses: Reloaded-Project/devops-rust-build-c-library@v1
  with:
    crate-name: my-crate
    target: x86_64-unknown-linux-gnu
    use-cross: true
```

### Custom Additional RUSTFLAGS

```yaml
- name: Build C Library
  uses: Reloaded-Project/devops-rust-build-c-library@v1
  with:
    crate-name: my-crate
    target: x86_64-unknown-linux-gnu
    additional-rustflags: -C opt-level=3
```

## Accessing the Built Artifacts

After a successful run, the built C library artifacts will be available as a downloadable
artifact in the GitHub Actions run.

To access the artifacts:

1. Navigate to the Actions tab in your repository.
2. Click on the workflow run that built the C library.
3. In the "Artifacts" section, you will find the generated artifacts, which you can download.

## Why this Exists?

Building C libraries from Rust projects can be a complex process, especially when
considering different target platforms, compiler flags, and optimizations like PGO.

This action simplifies the process by providing a configurable and reusable workflow
that handles the building of C libraries from Rust projects.

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements,
please open an issue or submit a pull request in this repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.