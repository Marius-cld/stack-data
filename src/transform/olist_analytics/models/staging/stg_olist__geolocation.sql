with source as (
    select * from {{ source('olist_raw', 'geolocation') }}
),

renamed as (
    select
        -- plusieurs points par préfixe : l'agrégation est faite dans int_geolocation_aggregated
        geolocation_zip_code_prefix as zip_code_prefix,
        geolocation_lat::numeric as latitude,
        geolocation_lng::numeric as longitude,
        initcap(geolocation_city) as city,
        upper(geolocation_state) as state
    from source
)

select * from renamed
