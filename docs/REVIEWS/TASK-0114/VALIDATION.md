# TASK-0114 Performance QA Evidence

Generated UTC: 2026-07-15 16:17:19 -05:00
Evidence directory: C:\Users\josh.adm\AppData\Local\Temp\ntk-evidence-2f17b082889140608fc22e1712bfd3ec

## Startup timing table from five cold launches

| Run | Started UTC | Config load | Manifest load | Module load | Plugin discovery | Static UI | Default-tab ready | Warmup start | Warmup complete | ReadyForUser | Shell |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| NTK-PERF-3ab301be26a247569d5584d98dfab269 | 2026-07-15T16:15:24.2215394+00:00 | 299 | 83 | 357 | 547 | 4791 |  |  |  |  | 4812 |
| NTK-PERF-78479e7034904c968da9b0a84b5cc5e8 | 2026-07-15T16:15:30.1541389+00:00 | 297 | 86 | 369 | 560 | 4825 |  |  |  |  | 4846 |
| NTK-PERF-cecb01fadd304d5c8c1a4853fc7dfb9d | 2026-07-15T16:15:36.1307682+00:00 | 318 | 86 | 376 | 528 | 4837 |  |  |  |  | 4858 |
| NTK-PERF-fb5fe40a46e243529b3b18930b51bebf | 2026-07-15T16:15:42.0868958+00:00 | 309 | 89 | 358 | 563 | 4946 |  |  |  |  | 4968 |
| NTK-PERF-22b97505a560450dbd7237e216d2c859 | 2026-07-15T16:15:48.1780928+00:00 | 317 | 86 | 366 | 551 | 4841 |  |  |  |  | 4864 |

## Cold and warm tab timing summary

| Metric | Samples | Average ms | Median ms | Best ms | Worst ms | P90 ms |
|---|---:|---:|---:|---:|---:|---:|
| gui.tab.first-render | 5 | 445 | 443 | 438 | 459 | 452.6 |
| gui.tab.switch | 5 | 581 | 574 | 573 | 599 | 593.4 |

## Resource summary

| Name | Samples | Working set avg/best/worst MB | Private avg/best/worst MB | Handles avg/best/worst | Threads avg/best/worst | CPU avg/best/worst ms |
|---|---:|---|---|---|---|---|
| run.start | 5 | 187.73/187.64/187.9 | 174.22/173.74/175.05 | 658.2/652/667 | 28.2/27/30 | 1206.25/1187.5/1234.38 |
| gui.startup.static-ui | 5 | 203.34/202.08/203.79 | 174.06/172.69/174.56 | 740/740/740 | 35/35/35 | 6584.38/6437.5/6921.88 |
| gui.startup.shell | 5 | 203.4/202.13/203.84 | 174.07/172.7/174.57 | 740/740/740 | 35/35/35 | 6606.25/6453.12/6953.12 |
| gui.shutdown.orphan-check | 5 | 205.58/204.37/205.98 | 175.37/174.02/175.84 | 764/764/764 | 35/35/35 | 6687.5/6531.25/7031.25 |
| gui.shutdown.complete | 5 | 205.59/204.38/205.99 | 175.37/174.02/175.84 | 764/764/764 | 35/35/35 | 6690.63/6531.25/7046.88 |
| run.complete | 5 | 205.72/204.5/206.12 | 175.39/174.04/175.86 | 764/764/764 | 35/35/35 | 6718.75/6562.5/7062.5 |

## Shutdown and orphan-process evidence

| Run | Shutdown start | Shutdown complete | Orphan count |
|---|---:|---:|---:|
| NTK-PERF-3ab301be26a247569d5584d98dfab269 | 96 | 97 | 0 |
| NTK-PERF-78479e7034904c968da9b0a84b5cc5e8 | 108 | 109 | 0 |
| NTK-PERF-cecb01fadd304d5c8c1a4853fc7dfb9d | 100 | 101 | 0 |
| NTK-PERF-fb5fe40a46e243529b3b18930b51bebf | 105 | 106 | 0 |
| NTK-PERF-22b97505a560450dbd7237e216d2c859 | 96 | 97 | 0 |

## Notes

- The startup table uses five fresh cold launches from the current TASK-0114 build.
- Tab timings are derived from the same launch artifacts to preserve a single machine/time basis.
- Shutdown telemetry is emitted on smoke exit paths and records orphan-process checks with zero orphan counts in this sample set.
- Resource snapshots include working set, private memory, handle count, thread count, and CPU time.
- The evidence remains local-only and excludes credentials and raw user content.
