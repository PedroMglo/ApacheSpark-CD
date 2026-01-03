# Índice Completo de Estudo de PySpark (do Zero ao Avançado)

> Focado em Spark 3.x / 4.x com API moderna (DataFrames, SparkSession, Structured Streaming). Evita APIs legacy (RDD/SQLContext/HiveContext), salvo para contexto e migração.

---

## 0. Fundamentos & Setup

0.1. O que é Spark e PySpark (batch vs streaming)
0.2. Arquitetura (Driver, Executors, Cluster Manager)
0.3. Componentes internos (Jobs, Stages, Tasks, DAG)
0.5. Primeira `SparkSession` (configs essenciais)
0.6. Estrutura de um job Spark (lifecycle)

---

## 1. Conceitos Básicos (Essenciais)

1.1. Lazy evaluation e lineage
1.2. Transformações vs ações
1.3. DAG e planos de execução (lógico/físico)
1.4. Paralelismo: partições, tasks e executores
1.5. Tipos de operações que geram shuffle
1.6. Boas práticas iniciais (evitar coletar, sizing mental de dados)

---

## 2. DataFrames (API Moderna)

2.1. Criar DataFrames

* `spark.createDataFrame` (listas/dicts/tuplos)
* Leitura de ficheiros (CSV/JSON/Parquet/ORC/Avro)
* Tabelas e catálogos (visão geral: managed/external)

2.2. Inspeção e compreensão do schema

* `show`, `printSchema`, `schema`, `dtypes`, `columns`, `describe`

2.3. Seleção e projeção

* `select`, `selectExpr`, `withColumn`, `drop`, `alias`, renames

2.4. Filtros e condições

* `filter`/`where`, `when/otherwise`, `isin`, `between`, `rlike`

2.5. Ordenação e limites

* `orderBy/sort`, `limit`, `distinct`, `dropDuplicates`

2.6. Conversões e interoperabilidade

* `toPandas()` (riscos e limites)
* Pandas API on Spark (introdução)

---

## 3. Colunas, Tipos e Funções (`pyspark.sql.functions`)

3.1. Tipos de dados

* `StructType`, `ArrayType`, `MapType`, `DecimalType`, timestamps

3.2. Operações com `Column`

* aritmética, lógicas, comparações
* strings (limpeza, regex)
* datas e timestamps (time zones, parsing, truncation)

3.3. Funções built-in essenciais

* `lit`, `col`, `expr`
* numéricas (rounding, stats básicas)
* strings (split, regexp, substring)
* datas (`to_date`, `date_add`, `datediff`, etc.)

3.4. Arrays e mapas

* `explode`, `posexplode`, `transform`, `filter`, `aggregate`
* `map_from_arrays`, `element_at`, `map_keys/values`

3.5. Expressões SQL via `expr` (quando usar)

---

## 4. Joins, GroupBy e Agregações

4.1. Tipos de join

* `inner`, `left`, `right`, `full`, `semi`, `anti`, `cross`

4.2. Condições de join, aliases e gestão de colunas duplicadas
4.3. `groupBy` + `agg` (padrões comuns)
4.4. Agregações avançadas

* `countDistinct`, `approx_count_distinct`, `collect_set/list`
* percentis (`percentile_approx`)

4.5. `rollup`, `cube`, `grouping sets`
4.6. Boas práticas: reduzir dados antes do join, evitar explosões

---

## 5. Window Functions (Janela Analítica)

5.1. Conceito de janela: `partitionBy` + `orderBy`
5.2. Ranking

* `row_number`, `rank`, `dense_rank`, `ntile`

5.3. Funções analíticas e de offset

* `lag`, `lead`, `first`, `last` (com/sem ignore nulls)

5.4. Frames

* `rowsBetween`, `rangeBetween`

5.5. Casos comuns

* métricas móveis, deduplicação, comparações linha-a-linha, SCD-like

---

## 6. I/O Moderno (Leitura e Escrita)

6.1. Formatos e quando usar

* CSV, JSON, Parquet, ORC, Avro (prós/cons)

6.2. Leitura: schema, inferência, corrupt records
6.3. Escrita: `mode`, `partitionBy`, `maxRecordsPerFile`
6.4. Gestão de partições no storage (layout e convenções)
6.5. “Small files problem” (causas e mitigação)
6.6. Tabelas: managed vs external; paths; metastore/catalog (visão geral)

---

## 7. Spark SQL (Atual)

7.1. Temp views e global temp views
7.2. `spark.sql` e interoperabilidade SQL ↔ DataFrames
7.3. Funções SQL vs `pyspark.sql.functions`
7.4. CTEs, subqueries, joins e window em SQL
7.5. Parâmetros e geração dinâmica de SQL com segurança

---

## 8. UDFs Modernas (e alternativas)

8.1. Quando evitar UDFs (impacto no Catalyst e performance)
8.2. UDF Python “normal” (`udf`)
8.3. Pandas UDFs (vectorized)

* scalar, grouped agg, grouped map

8.4. Tipagem, nullability e determinismo
8.5. Alternativas: funções nativas, SQL, `expr`, higher-order functions

---

## 9. Particionamento, Repartition e Performance Base

9.1. Partições: o que são, como afetam paralelismo
9.2. `repartition` vs `coalesce` (casos de uso)
9.3. Shuffle: mecanismos, custos e sintomas
9.4. Persistência

* `cache`, `persist` (níveis), `unpersist`

9.5. `explain` (logical/physical) e leitura do plano
9.6. Defaults importantes (partitions, parallelism, broadcast threshold)

---

## 10. Data Skew, Broadcast e Estratégias de Join

10.1. O que é skew e como identificar
10.2. Técnicas comuns

* salting
* repartition por chaves
* broadcast join (quando faz sentido)

10.3. Hints (`broadcast`, `merge`, `shuffle_hash`, etc.)
10.4. Trade-offs e validação via plano físico

---

## 11. Catalyst, AQE e Optimização

11.1. Catalyst Optimizer (visão prática)
11.2. Predicate pushdown e column pruning
11.3. Partition pruning e dynamic partition pruning
11.4. AQE (Adaptive Query Execution)

* coalesce de partições de shuffle
* escolha dinâmica de join strategy
* tratamento automático de skew (quando aplicável)

11.5. Estatísticas e CBO (quando importam)
11.6. Leitura crítica de `explain("formatted")`

---

## 12. Memory, GC, Spill e Sizing de Execução

12.1. Onde a memória é consumida (exec/storage/overhead)
12.2. Spill para disco: causas e mitigação
12.3. Garbage Collection: sintomas e sinais típicos
12.4. Serialização e impacto (conceitos)
12.5. Boas práticas para evitar OOM

* evitar `collect`/`toPandas`
* reduzir colunas/linhas cedo
* controlar cardinalidades em joins/aggregations

---

## 13. Structured Streaming (API Atual)

13.1. Conceitos: micro-batches, incremental execution, sinks
13.2. `readStream` vs `read` (diferenças reais)
13.3. Sinks

* console, ficheiros, tabelas, Kafka (visão geral)

13.4. Triggers

* processing time, once, available now (quando aplicável)

13.5. Checkpointing e tolerância a falhas
13.6. Streaming joins e aggregations
13.7. Watermarks e late data (modelos mentais)

---

## 14. Streaming Avançado (Stateful e Operação)

14.1. Stateful ops e state store (conceitos e limites)
14.2. Gestão de estado: crescimento, tuning e limpeza
14.3. Exactly-once vs at-least-once (prática por sink)
14.4. Backpressure e estabilidade operacional
14.5. Recuperação, reprocessamentos e compatibilidade de checkpoints
14.6. Observabilidade aplicada ao streaming (métricas e sintomas)

---

## 15. Integrações e Ecossistema

15.1. Metastore e catálogos (visão moderna)
15.2. Integração com storage (S3/ADLS/GCS/HDFS — conceitos)
15.3. Integração com sistemas externos

* JDBC, data warehouses, lake storage

15.4. Formatos e tabelas de lakehouse (visão geral: Delta/Iceberg/Hudi)

---

## 16. Lakehouse Tables na Prática (Delta/Iceberg/Hudi — Operações Essenciais)

16.1. Tabelas: schema evolution, partitions, snapshots/time travel (conceitos)
16.2. Upserts e deduplicação

* `MERGE` / padrões de atualização incremental

16.3. SCD (Type 1/2) com tabelas transacionais (padrões)
16.4. Manutenção e performance

* compaction/optimize (conceito)
* vacuum/expire snapshots (conceito)

16.5. Garantias e concorrência (noções práticas)

---

## 17. Desenvolvimento Profissional com PySpark

17.1. Organização de código

* módulos, funções puras, camadas (extract/transform/load)

17.2. Configuração e parametrização do job

* configs por ambiente, defaults, validação de inputs

17.3. Logging estruturado e debugging
17.4. Testes

* unit tests de transformações (pytest + Spark local)
* testes de schema e de qualidade de dados

17.5. Estilo e boas práticas (legibilidade, padrões, naming)

---

## 18. Deploy, Packaging e Execução em Cluster

18.1. `spark-submit` (essencial)

* `--conf`, `--packages`, `--jars`, `--py-files`

18.2. Empacotamento de dependências Python

* wheels/zip, ambientes, compatibilidade

18.3. Modos de deploy e noções de cluster managers

* local, standalone, YARN, Kubernetes (visão geral)

18.4. Gestão de configs em produção

* perfis por ambiente, secrets/credentials (conceitos)

18.5. Boas práticas de execução

* retries, idempotência, checkpoints/backfills (visão geral)

---

## 19. Observabilidade, Spark UI e Troubleshooting

19.1. Spark UI: Jobs, Stages, Tasks, Storage, SQL tab
19.2. Leitura de métricas comuns

* shuffle read/write, spill, skew, GC time, task time

19.3. Event logs e History Server (visão geral)
19.4. Debugging de problemas típicos

* OOM, skew, small files, long shuffles, deadlocks lógicos

19.5. Estratégia de diagnóstico (do sintoma → causa → solução)

---

## 20. Segurança, Governance e Boas Práticas de Dados

20.1. Acessos a storage e credenciais (conceitos por cloud)
20.2. Controlo de acesso a tabelas/metastore (visão geral)
20.3. Proteção de dados (encriptação, masking — noções)
20.4. Qualidade, contratos e validações (padrões)

---

## 21. MLlib (Machine Learning com Spark)

21.1. Visão geral (DataFrame-based)
21.2. Pipelines: Estimators, Transformers
21.3. Feature engineering

* `VectorAssembler`, `StringIndexer`, `OneHotEncoder`, etc.

21.4. Modelos principais (supervisionados e não supervisionados)
21.5. Avaliação e tuning

* `CrossValidator`, `TrainValidationSplit`

21.6. Spark ML vs scikit-learn (critérios de escolha)

---

## 22. Migração, Compatibilidade e Manutenção

22.1. Migrar de RDDs/legacy para DataFrames (quando necessário)
22.2. Diferenças relevantes entre Spark 2.x → 3.x → 4.x (visão geral)
22.3. Boas práticas para acompanhar mudanças de versão

* release notes, deprecations, testes de regressão

---

## 23. Recursos & Referências

23.1. Documentação oficial (PySpark, SQL, Structured Streaming)
23.2. Referências de tuning e troubleshooting
23.3. Repositórios e exemplos atualizados
23.4. Datasets públicos para treino (batch e streaming)
