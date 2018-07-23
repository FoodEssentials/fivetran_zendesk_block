view: zendesk_common_term_count {
  derived_table: {
    sql:
      WITH x AS (SELECT id, split(body, ' ') AS arr
        from `storied-landing-160804.zendesk.ticket_comment`)

    SELECT id, word FROM x, UNNEST(arr) as word
    ;;
  }

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }
  dimension: word {
    type: string
    sql: ${TABLE}.word ;;
  }
}
