with geolocation as (
    select * from {{ ref('stg_olist__geolocation') }}
),

aggregated as (
    select
        zip_code_prefix,
        round(avg(latitude), 6) as latitude,
        round(avg(longitude), 6) as longitude
    from geolocation
    -- quelques points aberrants hors du Brésil (cadre approximatif) fausseraient la moyenne
    where latitude between -34 and 6
        and longitude between -74 and -34
    group by 1
)

select * from aggregated
