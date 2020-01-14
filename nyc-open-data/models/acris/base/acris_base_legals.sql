
{{
    config(
        materialized = 'table'
    )
}}

SELECT document_id, record_type, borough, block, lot, easement, partial_lot, air_rights, subterranean_rights,
       property_type, street_number, street_name, addr_unit, good_through_date
  FROM raw.acris_personal_property_legals
 UNION ALL
SELECT document_id, record_type, borough, block, lot, easement, partial_lot, air_rights, subterranean_rights,
       property_type, street_number, street_name, unit AS addr_unit, good_through_date
  FROM raw.acris_real_property_legals

{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}