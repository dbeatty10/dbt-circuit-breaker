{%- materialization noop, default -%}

  -- Do nothing
  {% set sql = "" -%}

  {% call statement('main') -%}
    {{ sql }}
  {%- endcall %}

  -- This materialization creates no relations
  {{ return({'relations': []}) }}

{%- endmaterialization -%}
