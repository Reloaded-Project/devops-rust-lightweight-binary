<div align="center">
  <a href="https://github.com/Reloaded-Project/rust-lightweight-binary" target="_blank">
    <img src="assets/reloaded-logo.png" alt="reloaded Logo" width="100"/>
  </a>

  <h1 align="center">Reloaded Lightweight Rust Build Action</h1>

  <p>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License">
    </a>
  </p>
</div>

A GitHub Action for building optimized, lightweight Rust binaries and C libraries.

Uses nightly Rust and nightly-only features to minimize binary size and maximize performance:

- **Self-Built std**: Smaller binaries, better optimizations.
- **Abort on Panic**: Smaller binaries. (Can be disabled)
- **Profile Guided Optimization (PGO)**: Optimizes based on runtime usage patterns.
- **Cross-Compilation**: Via `cross-rs`.
- **Tests and Coverage**: Optional, via `devops-rust-test-and-coverage` action.

## Example Usage

As a single job/step of a workflow:

```yaml
build:
  strategy:
    matrix:
      include:
        - os: ubuntu-latest
          target: x86_64-unknown-linux-gnu
          use-pgo: true
          use-cross: false
        - os: windows-latest
          target: x86_64-pc-windows-msvc
          use-pgo: true
          use-cross: false
        - os: macos-latest
          target: aarch64-apple-darwin
          use-pgo: true
          use-cross: false
        - os: ubuntu-latest
          target: aarch64-unknown-linux-gnu
          use-pgo: false # no native runner
          use-cross: true
  runs-on: ${{ matrix.os }}
  steps:
    - name: Checkout Repository
      uses: actions/checkout@v4
    - name: Build Binary
      uses: Reloaded-Project/devops-rust-lightweight-binary@v1
      with:
        target: ${{ matrix.target }}
        crate-name: "my-crate"
        use-pgo: ${{ matrix.use-pgo }}
        use-cross: ${{ matrix.use-cross }}
```

> [!TIP]
> Adjust `rust-project-path` and `workspace-path` (if using cargo workspaces) if your project is not in the root folder `.`.

## Setup

To use this action in your own repository:

1. Create a new workflow file (e.g., `.github/workflows/build-c-library.yml`) in your repository.
2. Copy the example usage job from above into the new workflow file.
3. Customize the input parameters as needed for your project.

## Configuration

### Inputs

#### Parameters Used by This Action

These parameters are processed and used directly by the `rust-lightweight-binary` action:

| Input                       | Required | Default          | Description                                                                                                          |
| --------------------------- | -------- | ---------------- | -------------------------------------------------------------------------------------------------------------------- |
| `rust-project-path`         | No       | `.`              | Path to the Rust project                                                                                             |
| `workspace-path`            | No       | `.`              | Workspace folder where `target` directory is. Uses `rust-project-path` if not set.                                   |
| `pgo-project-path`          | No       | `.`              | Path to the Rust project used for gathering PGO data. Can be same or separate project.                               |
| `crate-name`                | Yes      |                  | Name of the Rust crate/package. Used for naming the artifact/release asset.                                          |
| `target`                    | Yes      |                  | The target platform for the Rust compiler                                                                            |
| `features`                  | No       | `''`             | Comma-separated list of features to include in the build                                                             |
| `no-default-features`       | No       | `false`          | Do not include default features in the build                                                                         |
| `use-pgo`                   | No       | `false`          | Use Profile-Guided Optimization [PGO] to build the library.                                                          |
| `pgo-benchmark-name`        | No       | `'my_benchmark'` | Benchmark name to use with PGO.                                                                                      |
| `use-cross`                 | No       | `false`          | Use cross-rs for building. If false, use cargo.                                                                      |
| `additional-rustflags`      | No       | `''`             | Additional RUSTFLAGS to pass to the Rust compiler                                                                    |
| `additional-rustc-args`     | No       | `''`             | Additional arguments to pass directly to `rustc`                                                                     |
| `rust-toolchain`            | No       | `nightly`        | The Rust toolchain to use. Can be nightly or a specific nightly version (e.g., nightly-2025-09-18).                  |
| `use-cache`                 | No       | `true`           | Enable or disable the build cache using `Swatinem/rust-cache`.                                                       |
| `upload-artifacts`          | No       | `true`           | Upload the built artifacts as a GitHub Actions artifact                                                              |
| `upload-symbols-separately` | No       | `true`           | Upload debug symbol files (.pdb, .dwp, .dSYM) as separate artifacts instead of bundling with main artifacts          |
| `abort-on-panic`            | No       | `true`           | Abort immediately on panic. If false, the default panic handler is used.                                             |
| `build-library`             | No       | `false`          | Build a library instead of a binary.                                                                                 |
| `run-tests-and-coverage`    | No       | `false`          | Run tests and coverage using the `devops-rust-test-and-coverage` action.                                             |
| `size-optimized-std`        | No       | `false`          | Builds `std` with size optimizations, such as reduced `core::fmt` footprint.                                         |
| `additional-std-features`   | No       | ``               | Specify extra `build-std` features.                                                                                  |
| `use-friendly-target-names` | No       | `true`           | Transform target triples to user-friendly names (e.g., `x86_64-unknown-linux-gnu` -> `linux-x64`) in artifact names. |

#### Parameters Passed Through to `devops-rust-test-and-coverage`

These parameters are only used when `run-tests-and-coverage` is enabled and are passed directly to the [devops-rust-test-and-coverage][devops-test-coverage] action:

| Input                        | Required | Default              | Description                                                                                           |
| ---------------------------- | -------- | -------------------- | ----------------------------------------------------------------------------------------------------- |
| `upload-coverage-to-codecov` | No       | `true`               | Whether to upload coverage to Codecov                                                                 |
| `codecov-token`              | No       |                      | Codecov token for uploading coverage                                                                  |
| `use-tarpaulin`              | No       | `true`               | Whether to use Tarpaulin for code coverage. If false, only runs tests.                                |
| `use-binstall`               | No       | `true`               | Whether to use cargo-binstall for installing components like tarpaulin. If false, uses cargo install. |
| `install-binstall`           | No       | `true`               | Whether to install cargo-binstall. If false, assumes it is already available in the environment.      |
| `additional-test-args`       | No       | `''`                 | Additional arguments passed directly to the cargo test command.                                       |
| `additional-tarpaulin-args`  | No       | `''`                 | Additional arguments passed directly to the cargo tarpaulin command.                                  |
| `codecov-flags`              | No       | `'unittests'`        | Flags to pass to Codecov for organizing coverage reports.                                             |
| `codecov-name`               | No       | `'codecov-umbrella'` | Custom defined name for the coverage upload.                                                          |

**Note:** The following parameters are used by both this action AND passed through to the test action: `target`, `features`, `no-default-features`, `use-cross`.

> **Note:** Stable and beta toolchains are not supported due to required nightly features. Only nightly and specific nightly versions (e.g., `nightly-2025-09-18`) are supported.

### Setting up Profile-Guided Optimization (PGO)

Profile-Guided Optimization works by compiling and executing a benchmark whose name and project
can be defined by `pgo-benchmark-name` and `pgo-project-path` respectively. So you should strive
to keep the benchmark as close to the final usage of your application as possible.

A benchmark for PGO can be defined as follows:

```rust
// Regular benchmarks, not PGO
#[cfg(not(feature = "pgo"))]
{
    bench_estimate(c);
    bench_decompress(c);
    bench_compress_file(c);
    bench_create_dict(c);
}

// Benchmark with realistic usage patterns for PGO.
#[cfg(feature = "pgo")]
{
    generate_pgo_data();
}
```

Then said profile is used to build the final version of your application.

For PGO to work, the `target` platform must be the same as the host that generated the profiling
data. Sometimes you can get away with using `cross` to achieve this, for example:

```yaml
# Host is x86-linux but this seems to work just a-ok!
target: aarch64-unknown-linux-gnu # x64 host to to aarch64 simulated guest
use-pgo: true
use-cross: true
```

If the process fails, your CI will fail, so do experiment.

## Running Tests and Coverage

Set `run-tests-and-coverage: true` to run tests and generate coverage after the build.

This invokes [devops-rust-test-and-coverage][devops-test-coverage] with the same configuration (`target`, `features`, `use-cross`, etc.).

- Tests run via `cargo` or `cross` (based on `use-cross`)
- Coverage via Tarpaulin when `use-tarpaulin: true` (ignored if `use-cross: true`)

## Building Libraries

Set `build-library: true` to build a library instead of a binary (equivalent to `crate-type = ["cdylib", "staticlib"]`).

Artifacts include static (`.a`, `.lib`) and dynamic (`.so`, `.dll`, `.dylib`) libraries depending on target.

## Examples

Find more examples in [the tests](./.github/workflows/test-rust-build-c-library-workflow.yml).

### Custom `rustc` Arguments and RUSTFLAGS

```yaml
- name: Build C Library
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    crate-name: my-crate
    target: x86_64-unknown-linux-gnu
    additional-rustflags: -C opt-level=3
    additional-rustc-args: --all-features
```

### Pin to Specific Nightly Version

```yaml
- name: Build C Library with Specific Nightly
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    crate-name: my-crate
    target: x86_64-unknown-linux-gnu
    rust-toolchain: nightly-2025-09-18
```

### Building Multiple Projects

#### Serial Builds (Single Job)

If you are building multiple projects, for example multiple projects in a single workspace, 
build them in a single job:

```yaml
- name: Build API Crate
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    rust-project-path: projects/api-crate
    crate-name: api-crate
    target: x86_64-unknown-linux-gnu
    use-cache: true  # Only first build enables cache
    upload-artifacts: true
    # install-binstall: true (default)

- name: Build CLI Crate
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    rust-project-path: projects/cli-crate
    crate-name: cli-crate
    target: x86_64-unknown-linux-gnu
    use-cache: false  # Subsequent builds disable cache
    install-binstall: false  # Avoid installing cargo-binstall again
    upload-artifacts: true
```

The cache is restored in `Build API Crate` and saved after completion of `Build CLI Crate`.
So you should only set `use-cache` on the first project.

> [!WARNING]
>
> If you are using [devops-test-coverage] action, that also creates a cache by default.
> Be aware of this, you may want to set `use-cache` false if running tests at the end, or set
> `use-cache` false on `devops-rust-lightweight-binary` if tests are ran first.
>
> Additionally, cargo-binstall will be installed by default. If you want to avoid installing
> cargo-binstall multiple times across multiple build steps, set `install-binstall` to false
> on subsequent steps.
> 
> ```yaml
> - name: Run Tests
>   uses: Reloaded-Project/devops-rust-test-and-coverage@v1
>   with:
>     target: ${{ matrix.target }}
>     use-cross: ${{ matrix.use-cross }}
>     codecov-token: ${{ secrets.CODECOV_TOKEN }}\
>     # use-cache: true # use-cache is enabled by default
>     # install-binstall: true # install-binstall is enabled by default
> ```

#### Parallel Builds

If you are building multiple projects with either different compiler settings, features, or targets, 
build them in separate jobs:

```yaml
jobs:
  build-api:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Reloaded-Project/devops-rust-lightweight-binary@v1
        with:
          rust-project-path: projects/api-crate
          crate-name: api-crate
          target: x86_64-unknown-linux-gnu
          use-cache: true # this is the default
          upload-artifacts: true

  build-cli:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Reloaded-Project/devops-rust-lightweight-binary@v1
        with:
          rust-project-path: projects/cli-crate
          crate-name: cli-crate
          target: x86_64-unknown-linux-gnu
          use-cache: true # this is the default
          upload-artifacts: true
```

## Accessing the Built Artifacts

After a successful run, the built artifacts will be available as a downloadable
artifact in the GitHub Actions run.

For binary builds, the artifact will be named `${{ inputs.crate-name }}-${{ inputs.target }}-${{ inputs.features }}`.

For library builds, the artifact will be named `C-Library-${{ inputs.crate-name }}-${{ inputs.target }}-${{ inputs.features }}`.

When `use-friendly-target-names` is enabled, the target triple in artifact names is replaced with a
user-friendly platform identifier (e.g., `x86_64-unknown-linux-gnu` becomes `linux-x64`,
`aarch64-apple-darwin` becomes `macos-arm64`). Unmapped targets fall back to the raw target triple.

When `upload-symbols-separately` is enabled (default), debug symbols are uploaded as separate artifacts:

- Binary symbols: `${{ inputs.crate-name }}-${{ inputs.target }}-${{ inputs.features }}.symbols`
- Library symbols: `C-Library-${{ inputs.crate-name }}-${{ inputs.target }}-${{ inputs.features }}.symbols`

To access the artifacts:

1. Navigate to the Actions tab in your repository.
2. Click on the workflow run that built the artifacts.
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

[devops-test-coverage]: https://github.com/Reloaded-Project/devops-rust-test-and-coverage