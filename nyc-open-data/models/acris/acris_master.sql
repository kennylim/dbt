{{
    config(
        materialized = 'table'
    )
}}

WITH acris_master AS (SELECT CONCAT(apl.borough, LPAD(apl.block, 5, '0'), LPAD(apl.lot, 4, '0')) AS bbl,
                                apl.document_id,
                                apl.record_type,
                                app.party_type,
                                app.name,
                                apl.borough::INT,
                                apl.block::INT,
                                apl.lot::INT,
                                apl.easement,
                                apl.partial_lot,
                                apl.air_rights,
                                apl.subterranean_rights,
                                apl.property_type,
                                apl.street_number,
                                apl.street_name,
                                apl.addr_unit,
                                apm.recorded_datetime::TIMESTAMP WITH TIME ZONE,
                                apl.good_through_date::TIMESTAMP WITH TIME ZONE,
                                apm.crfn,
                                apm.document_amt::NUMERIC,
                                apm.percent_trans::NUMERIC,
                                apk.sequence_number::INT,
                                apk.remark_text
                          FROM "usa"."nyc"."acris_base_parties" AS app
                                   LEFT JOIN "usa"."nyc"."acris_base_legals" AS apl
                                   ON apl.document_id = app.document_id
                                   LEFT JOIN "usa"."nyc"."acris_base_master" AS apm
                                   ON apm.document_id = app.document_id
                                   LEFT JOIN "usa"."nyc"."acris_base_references" AS apr
                                   ON apr.document_id = app.document_id
                                   LEFT JOIN "usa"."nyc"."acris_base_remarks" AS apk
                                   ON apk.document_id = app.document_id)
 SELECT DISTINCT ON (bbl, document_id, record_type, party_type) *
  FROM acris_master
 WHERE bbl IS NOT NULL
   AND document_id IS NOT NULL
   AND record_type IS NOT NULL
   AND party_type IS NOT NULL

{{
  config({
    "post-hook" : [
        'create index if not exists {{ this.name }}__index_on_bbl on {{ this }} ("bbl")',
        'create index if not exists {{ this.name }}__index_on_document_id on {{ this }} ("document_id")',
        {"sql": "vacuum {{this.schema}}.{{this.name}}", "transaction": False},
      "grant select on {{ this }} to db_reader"

  ]})
}}