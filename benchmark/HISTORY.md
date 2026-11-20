# Benchmark history

Generated from the versions of [benchmark/results.json](results.json) in the git history (following only the first parent of merges) by `bundle exec rake benchmark` or `bundle exec rake benchmark:history`. Don't edit this file by hand. The latest results, and what each step measures, are in [RESULTS.md](RESULTS.md).

Each run is labeled with the commit it measured, or the git ref (e.g. a release tag) for runs of earlier versions. `*` marks runs with uncommitted changes.

## Runs

| Run | Date | Curlybars | Ruby | YJIT | ActionView | Machine |
|---|---|---|---|---|---|---|
| v1.16.1 | 2026-11-20 | 1.16.1 | 3.4.12 | disabled | 8.1.3.1 | Apple M1 Pro, Darwin 25.6.0 arm64 |

## Allocations per call

Allocations don't depend on the machine, but can change with the Ruby and Rails versions (see "Runs").

### small

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "small: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 2400
  line "Lex" [981]
  line "Parse" [2132]
  line "Compile" [120]
  line "Eval" [322]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "small: allocations during Render"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 400
  line "Render" [360]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 981 | 2,132 | 120 | 322 | 360 | 419 |

### medium

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "medium: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 5000
  line "Lex" [2175]
  line "Parse" [4513]
  line "Compile" [665]
  line "Eval" [617]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "medium: allocations during Render"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 56000
  line "Render" [50337]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 2,175 | 4,513 | 665 | 617 | 50,337 | 50,392 |

### large

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "large: allocations during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 12000
  line "Lex" [5760]
  line "Parse" [10175]
  line "Compile" [1254]
  line "Eval" [1172]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "large: allocations during Render"
  x-axis ["v1.16.1"]
  y-axis "Objects" 0 --> 120000
  line "Render" [101622]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 5,760 | 10,175 | 1,254 | 1,172 | 101,622 | 101,679 |


## Time per call

Times are only comparable between runs on the same machine, Ruby version and YJIT setting, so they are grouped by those.

### Apple M1 Pro, Darwin arm64, Ruby 3.4.12, YJIT disabled

#### small

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "small: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 0.33
  line "Lex" [0.151]
  line "Parse" [0.248]
  line "Compile" [0.022]
  line "Eval" [0.297]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "small: time during Render"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 0.068
  line "Render" [0.061]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 150.5 µs | 248.4 µs | 22.2 µs | 296.5 µs | 61.3 µs | 81.3 µs |

#### medium

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "medium: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 0.65
  line "Lex" [0.33]
  line "Parse" [0.539]
  line "Compile" [0.095]
  line "Eval" [0.59]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "medium: time during Render"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 18
  line "Render" [16.1]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 329.8 µs | 538.9 µs | 94.7 µs | 589.7 µs | 16.10 ms | 16.12 ms |

#### large

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#0072B2, #E69F00, #009E73, #CC79A7"
---
xychart-beta
  title "large: time during Lex, Parse, Compile and Eval"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 1.4
  line "Lex" [0.897]
  line "Parse" [1.247]
  line "Compile" [0.186]
  line "Eval" [1.156]
```

```mermaid
---
config:
  themeVariables:
    xyChart:
      plotColorPalette: "#D55E00"
---
xychart-beta
  title "large: time during Render"
  x-axis ["v1.16.1"]
  y-axis "ms" 0 --> 59
  line "Render" [52.9]
```

| Run | Lex | Parse | Compile | Eval | Render | Render with ActionView |
|---|--:|--:|--:|--:|--:|--:|
| v1.16.1 | 896.9 µs | 1.25 ms | 186.2 µs | 1.16 ms | 52.90 ms | 53.01 ms |

