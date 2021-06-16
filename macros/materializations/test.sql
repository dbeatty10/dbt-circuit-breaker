{%- materialization test, default -%}

  -- Run the test
  {% call statement('main', fetch_result=True) -%}
    {{ sql }}
  {%- endcall %}

  -- Assume the first column of the first row is the count of test exceptions
  {%- set results = load_result('main').table  -%}
  {%- set count = results[0][0] -%}

  -- Only PASS if there is a count of 0
  {% if count != 0 -%}
    {{ log("FAIL " ~ count) }}
    {{ exceptions.raise_database_error("Test FAIL " ~ count) }}
  {%- else %}
    {{ log("PASS " ~ count) }}
  {%- endif %}

  -- This materialization creates no relations
  {{ return({'relations': []}) }}

{%- endmaterialization -%}
