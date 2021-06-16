# dbt-circuit-breaker

**dbt-circuit-breaker** is a plugin for [**dbt**](https://github.com/fishtown-analytics/dbt) interrupts data transformations after a fault is detected. By injecting the functionality of `dbt test` into `dbt run`, it allows for a subset of tests for a model to be executed _before_ downstream models are built.

This project name is inspired by the description of a circuit breaker on Wikipedia:
> A circuit breaker is an automatically operated electrical switch designed to protect an electrical circuit from damage caused by excess current from an overload or short circuit. Its basic function is to interrupt current flow after a fault is detected.

## Install

Include in `packages.yml`

```yaml
packages:
  - package: dbeatty10/dbt-circuit-breaker
    version: [">=0.1.0", "<0.2.0"]
```

## Usage

See below for example source code for injecting dbt tests whenever you execute:
```shell
dbt run
```

### Source tree
```
.
└── your_dbt_project/
    └── models/
        ├── mart/
        │   ├── base_table.sql
        │   └── derived_table.sql
        ├── test_suites/
        │   └── suite__base_table.sql
        └── tests/
            ├── base_table__test_1.sql
            └── base_table__test_2.sql
```

### Code

The following example assumes that the [**dbt-utils**](https://github.com/fishtown-analytics/dbt-utils) package is installed along with the dbt-circuit-breaker package.

`models/mart/base_table.sql`
```sql
{{ config(materialized='table')}}

select * from {{ source('raw', 'your_raw_table') }}
```

`models/mart/derived_table.sql`
```sql
{{ config(materialized='table')}}

select * from {{ dbt_circuit_breaker.tested('base_table', 'suite__base_table') }}
```

`models/tests/base_table__test_1.sql`
```sql
{{ config (materialized="test") }}

{{ dbt_utils.test_expression_is_true(ref("base_table"), expression="1=1") }}
```

`models/tests/base_table__test_2.sql`
```sql
{{ config (materialized="test") }}

{{ dbt_utils.test_expression_is_true(ref("base_table"), expression="2=2") }}
```

`models/test_suites/suite__base_table.sql`
```sql
{{ config(materialized='noop')}}

-- All the test materializations for a single model:
-- {{ ref("base_table__test_1") }}
-- {{ ref("base_table__test_2") }}
-- {{ ref("base_table__test_3") }}
```

### Explanation
Note how instances of the `ref()` macro are replaced with `tested()` in the downstream derived model.

`tested(downstream_table, upstream_table)` is functionally equivalent to [forcing dependencies](https://docs.getdbt.com/reference/dbt-jinja-functions/ref#forcing-dependencies) like the following:
```sql
-- depends on: {{ ref("upstream_table") }}
select * from {{ ref('downstream_table') }}
```


## Quality of life

To lessen the typing burden, you can define the following macro within your _local_ project:

`models/mart/derived_table.sql`
```sql
{% macro tested(model_name, test_suite) %}

  {% do return(dbt_circuit_breaker.tested(model_name, test_suite)) %}

{% endmacro %}
```

This allows rewriting this:
```sql
select * from {{ dbt_circuit_breaker.tested('base_table', 'suite__base_table') }}
```
more succinctly as:
```sql
select * from {{ tested('base_table', 'suite__base_table') }}
```
