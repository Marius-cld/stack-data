{#
    Par défaut, dbt préfixe le schéma personnalisé par celui du profil (analytics_staging).
    Ici, on utilise le nom tel quel pour obtenir raw -> staging -> intermediate -> marts.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
