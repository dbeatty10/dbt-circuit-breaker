{% macro tested(model_name, test_suite) %}

  {#- Depend upon the test suite -#}
  {% set suite_relation = builtins.ref(test_suite) %}

  {#- Yield the relation for the model -#}
  {% do return(builtins.ref(model_name)) %}

{% endmacro %}

