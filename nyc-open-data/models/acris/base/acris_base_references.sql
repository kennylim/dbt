{{
    config(
        materialized = 'table'
    )
}}

SELECT document_id, record_type, crfn, good_through_date, doc_id_ref, file_nbr
  FROM raw.acris_personal_property_references
 UNION ALL
SELECT document_id, record_type, reference_by_crfn_ AS crfn, good_through_date, reference_by_doc_id AS doc_id_ref,
       NULL AS file_nbr
  FROM raw.acris_real_property_references

{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}