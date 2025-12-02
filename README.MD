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

#### Commonly Used

| Input                    | Required | Default | Description                                                                          |
| ------------------------ | -------- | ------- | ------------------------------------------------------------------------------------ |
| `rust-project-path`      | No       | `.`     | Path to the Rust project                                                             |
| `workspace-path`         | No       | `.`     | Workspace folder where `target` directory is. Uses `rust-project-path` if not set.   |
| `build-library`          | No       | `false` | Build a library instead of a binary.                                                 |
| `target`                 | Yes      |         | The target platform for the Rust compiler                                            |
| `features`               | No       | `''`    | Comma-separated list of features to include in the build                             |
| `run-tests-and-coverage` | No       | `false` | Run tests and coverage using the `devops-rust-test-and-coverage` action.             |
| `use-cache`              | No       | `true`  | Enable or disable the build cache using `Swatinem/rust-cache`.                       |

#### Build Configuration

| Input                 | Required | Default   | Description                                                                                         |
| --------------------- | -------- | --------- | --------------------------------------------------------------------------------------------------- |
| `no-default-features` | No       | `false`   | Do not include default features in the build                                                        |
| `rust-toolchain`      | No       | `nightly` | The Rust toolchain to use. Can be nightly or a specific nightly version (e.g., nightly-2025-09-18). |
| `use-cross`           | No       | `false`   | Use cross-rs for building. If false, use cargo.                                                     |

#### Optimization Options

| Input                | Required | Default          | Description                                                                            |
| -------------------- | -------- | ---------------- | -------------------------------------------------------------------------------------- |
| `use-pgo`            | No       | `false`          | Use Profile-Guided Optimization [PGO] to build the library.                            |
| `pgo-project-path`   | No       | `.`              | Path to the Rust project used for gathering PGO data. Can be same or separate project. |
| `pgo-benchmark-name` | No       | `'my_benchmark'` | Benchmark name to use with PGO.                                                        |
| `abort-on-panic`     | No       | `true`           | Abort immediately on panic. If false, the default panic handler is used.               |
| `size-optimized-std` | No       | `false`          | Builds `std` with size optimizations, such as reduced `core::fmt` footprint.           |

#### Artifact & Output Settings

| Input                       | Required | Default | Description                                                                                                                                    |
| --------------------------- | -------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `upload-artifacts`          | No       | `true`  | Upload the built artifacts as a GitHub Actions artifact                                                                                        |
| `upload-symbols-separately` | No       | `true`  | Upload debug symbol files (.pdb, .dwp, .dSYM) as separate artifacts instead of bundling with main artifacts                                    |
| `use-friendly-target-names` | No       | `true`  | Transform target triples to user-friendly names (e.g., `x86_64-unknown-linux-gnu` -> `linux-x64`) in artifact names.                           |
| `artifact-prefix`           | No       | `''`    | Prefix for artifact names. Combined with target/features to form final name (e.g., `MyApp` -> `MyApp-linux-x64`). If empty, no prefix is used. |

#### Advanced / Low-Level

| Input                     | Required | Default | Description                                       |
| ------------------------- | -------- | ------- | ------------------------------------------------- |
| `additional-rustflags`    | No       | `''`    | Additional RUSTFLAGS to pass to the Rust compiler |
| `additional-rustc-args`   | No       | `''`    | Additional arguments to pass directly to `rustc`  |
| `additional-std-features` | No       | ``      | Specify extra `build-std` features.               |

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

PGO compiles and runs a benchmark (configured via `pgo-benchmark-name` and `pgo-project-path`) to collect runtime data, then uses that profile to optimize the final build. Keep the benchmark close to real usage patterns:

```rust
#[cfg(not(feature = "pgo"))]
{
    // Regular benchmarks, unrealistic for profiling, exclude
    bench_estimate(c);
    bench_decompress(c);
}

#[cfg(feature = "pgo")]
{
    // Realistic usage patterns for PGO
    generate_pgo_data();
}
```

PGO requires the target platform to match the host. With `use-cross: true`, cross-compilation may work:

```yaml
target: aarch64-unknown-linux-gnu  # x64 host to aarch64 simulated guest
use-pgo: true
use-cross: true
```

If the process fails, your CI will fail, so experiment to find what works.

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

> [!TIP]
> The best approach depends on whether your builds share the same settings.

#### Same Settings

When building multiple crates within a workspace with the same settings, use a single job.
Shared dependencies are compiled once and reused:

```yaml
- name: Build API Crate
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    rust-project-path: projects/api-crate
    crate-name: api-crate
    target: x86_64-unknown-linux-gnu
    use-cache: true  # first step: restore cache
    install-binstall: true  # default

- name: Build CLI Crate
  uses: Reloaded-Project/devops-rust-lightweight-binary@v1
  with:
    rust-project-path: projects/cli-crate
    crate-name: cli-crate
    target: x86_64-unknown-linux-gnu
    use-cache: false  # subsequent steps: disable to avoid duplicate save
    install-binstall: false  # already installed above
```

> [!NOTE]
> Only enable `use-cache` on the first step. The cache is restored at the start and saved after the job completes.
> Same applies to `install-binstall` - only install once per job.

#### Different Settings

When building crates with different settings, use separate jobs to avoid cache conflicts:

```yaml
jobs:
  build-standard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Reloaded-Project/devops-rust-lightweight-binary@v1
        with:
          crate-name: my-crate
          target: x86_64-unknown-linux-gnu
          features: ""

  build-with-simd:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Reloaded-Project/devops-rust-lightweight-binary@v1
        with:
          crate-name: my-crate
          target: x86_64-unknown-linux-gnu
          features: "simd,avx2"
```

Building these in a single job would cause cache conflicts since both use the same target but different features.

## Accessing the Built Artifacts

After a successful run, the built artifacts will be available as a downloadable
artifact in the GitHub Actions run.

### Artifact Naming

Artifact names follow the pattern: `{artifact-prefix}-{target}[-features]` or `{target}[-features]` when no prefix is set.

| Scenario                  | Example Name                             |
| ------------------------- | ---------------------------------------- |
| No prefix, friendly names | `linux-x64`, `windows-arm64`             |
| With prefix `MyApp`       | `MyApp-linux-x64`, `MyApp-windows-arm64` |
| With features `simd,avx2` | `linux-x64-simd,avx2`                    |
| With prefix and features  | `MyApp-linux-x64-simd,avx2`              |

When `use-friendly-target-names` is enabled (default), the target triple is replaced with a
user-friendly platform identifier (e.g., `x86_64-unknown-linux-gnu` becomes `linux-x64`,
`aarch64-apple-darwin` becomes `macos-arm64`). Unmapped targets fall back to the raw target triple.

When `upload-symbols-separately` is enabled (default), debug symbols are uploaded as separate artifacts
with a `.symbols` suffix:

- Main artifact: `MyApp-linux-x64`
- Symbol artifact: `MyApp-linux-x64.symbols`

### Downloading Artifacts

To access the artifacts:

1. Navigate to the Actions tab in your repository.
2. Click on the workflow run that built the artifacts.
3. In the "Artifacts" section, you will find the generated artifacts, which you can download.

## Deprecated Options

### `crate-name` Parameter

| Input        | Required | Default | Description                                                                   |
| ------------ | -------- | ------- | ----------------------------------------------------------------------------- |
| `crate-name` | No       | `''`    | Name of the Rust crate/package. Used for cache key and artifact directory.   |

The `crate-name` parameter is still used for:
- **Cache key**: When provided, it helps create unique cache keys for your builds
- **Artifact directory**: Used in the `ARTIFACT_OUT_DIR` path construction

However, using `crate-name` for **artifact naming** is deprecated. Please use `artifact-prefix` instead.

#### Legacy Artifact Naming Behaviour

For backwards compatibility, if `crate-name` is set and `artifact-prefix` is not provided, the legacy
naming behaviour is used:

- Binary artifacts: `{crate-name}-{target}[-features]`
- Library artifacts: `C-Library-{crate-name}-{target}[-features]`

A deprecation warning will appear in the workflow logs when this legacy behaviour is triggered.

**Migration**: Replace `crate-name: my-crate` with `artifact-prefix: my-crate` for binaries, or
`artifact-prefix: C-Library-my-crate` for libraries to maintain the same artifact names.

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