{{
    config(
        materialized = 'table'
    )
}}

SELECT document_id, record_type, party_type, name, address_1, country, city, state, zip, good_through_date, address_2
  FROM raw.acris_personal_property_parties
 UNION ALL
SELECT document_id, record_type, party_type, name, address_1, country, city, state, zip, good_through_date, address_2
  FROM raw.acris_real_property_parties


{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}