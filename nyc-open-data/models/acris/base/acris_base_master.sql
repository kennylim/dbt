{{
    config(
        materialized = 'table'
    )
}}

SELECT document_id, record_type, crfn, recorded_borough, doc_type, NULL AS document_date, document_amt,
       recorded_datetime, modified_date, reel_yr, reel_nbr, reel_pg, NULL AS percent_trans, good_through_date
  FROM raw.acris_personal_property_master
 UNION ALL
SELECT document_id, record_type, crfn, recorded_borough, doc_type, document_date, document_amt, recorded_datetime,
       modified_date, reel_yr, reel_nbr, reel_pg, percent_trans, good_through_date
  FROM raw.acris_real_property_master

{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}