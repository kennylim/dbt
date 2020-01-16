{{
    config(
        materialized = 'table'
    )
}}

SELECT document_id, record_type, sequence_number, remark_text, good_through_date
  FROM raw.acris_personal_property_remarks
 UNION ALL
SELECT document_id, record_type, sequence_number, remark_text, good_through_date
  FROM raw.acris_real_property_remarks



{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}