include: "_zendesk_variables.view"

view: ticket {
  extends: [_variables]
  sql_table_name: zendesk.ticket ;;

  # ----- database fields -----
  dimension: id {
    description: "Unique ID for the Zendesk ticket."
    type: number
    sql: ${TABLE}.id ;;
    primary_key: yes
    group_label: "Basic Ticket Information"
  }

  dimension: id_direct_link {
    group_label: "Basic Ticket Information"
    type: number
    sql: ${id} ;;
    html: <a href="https://{{ ticket._ZENDESK_INSTANCE_DOMAIN._value }}.zendesk.com/agent/tickets/{{ value }}" target="_blank"><img src="http://www.google.com/s2/favicons?domain=www.zendesk.com" height=16 width=16> {{ value }}</a> ;;
    hidden: yes
  }

  dimension: allow_channelback {
    group_label: "Basic Ticket Information"
    description: "Is false if channelback is disabled, true otherwise. Only applicable for channels framework ticket."
    type: yesno
    sql: ${TABLE}.allow_channelback ;;
  }

  dimension: description {
    group_label: "Basic Ticket Information"
    description: "The first comment on the ticket."
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: has_incidents {
    group_label: "Basic Ticket Information"
    type: yesno
    sql: ${TABLE}.has_incidents ;;
  }

  dimension: is_public {
    group_label: "Basic Ticket Information"
    description: "If the Zendesk ticket is public."
    type: yesno
    sql: ${TABLE}.is_public ;;
  }

  dimension: custom_ticket_categories {
    label: "Ticket Categories"
    description: "A required field within a Zendesk ticket. Explaining which platform the ticket occured within, and what the issue was."
    type: string
    sql: ${TABLE}.custom_ticket_categories ;;
    group_label: "Basic Ticket Information"
  }

  dimension: ticket_category {
    group_label: "Basic Ticket Information"
    label: "Combined Ticket Categories"
    description: "Client-facing ticket categories bucketing custom ticket categories."
    case: {
      when: {
        sql: ${custom_ticket_categories} = "api" ;;
        label:  "API"
      }
      when: {
        sql: ${custom_ticket_categories} = "onboard__missing_product_" ;;
        label:  "Missing Product"
      }
      when: {
        sql: ${custom_ticket_categories} =  "onboard__updating_data" ;;
        label: "Updating Data"
      }
      when: {
        sql: ${custom_ticket_categories} IN("publish__bug__p3s2", "publish__bug__p2s3","publish__bug__p3s3","publish__bug__p2s2","explore__bug","explore__bug__p2s2","capture__bug");;
        label: "Bug"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__check_in" ;;
        label: "Check In"
      }
      when: {
        sql: ${custom_ticket_categories} IN("data_error","onboard__data_error","explore__data_error","capture__data_error");;
        label: "Data Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__account_error" ;;
        label: "Account Error"
      }
      when: {
        sql: ${custom_ticket_categories} IN("data_request","explore__data_request","capture__data_request");;
        label: "Data Request"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__exemption";;
        label: "Exemption"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__expo";;
        label: "Expo"
      }
      when: {
        sql: ${custom_ticket_categories} IN("feature_request/_product_feedback","explore__feature_request/_product_feedback","capture__feature_request/_product_feedback");;
        label: "Feature Request/Product Feedback"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_processing_issues";;
        label: "Image Processing Issues"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__image_issues";;
        label: "Image Issues"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_provider";;
        label: "Image Provider"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_requirements";;
        label: "Image Requirements"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__li_initiative_overview";;
        label: "Initiative Overview"
      }
      when: {
        sql: ${custom_ticket_categories}= "internal_request";;
        label: "Internal Request"
      }
      when: {
        sql: ${custom_ticket_categories} IN("publish__other", "publish__unknown", "onboard__other","explore__other", "capture__other", "capture__unknown");;
        label: "Other"
      }
      when: {
        sql: ${custom_ticket_categories} IN("platform_downtime","capture__platform_downtime");;
        label: "Platform Downtime"
      }
      when: {
        sql: ${custom_ticket_categories} IN("onboard__portal_navigation","onboard__portal_navigation__timeline_questions", "onboard__portal_navigation__products_with_issues", "onboard__portal_navigation__products_ready_for_processing");;
        label: "Portal Navigation"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__registration_error";;
        label: "Registration Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__submission_portal_error";;
        label: "Submission Portal Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__third_party_questions";;
        label: "Third Party Questions"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__change_of_contact";;
        label: "Change of Contact"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__contact_request";;
        label: "Contact Request"
      }
      when: {
        sql: ${custom_ticket_categories} IN("training_gap","explore__training_gap","capture__training_gap");;
        label: "Training Gap"
      }
      when: {
        sql: ${custom_ticket_categories} IN("user_permissions_and_admin","explore__user_permissions_and_admin","capture__user_permissions_and_admin");;
        label: "User Permissions and Admin"
      }
    }
  }

  dimension: Platform {
    group_label: "Basic Ticket Information"
    description: "Custom ticket categories grouped by different LI platform"
    case: {
      when: {
        sql:${custom_ticket_categories} IN("onboard__account_error", "onboard__change_of_contact", "onboard__check_in", "onboard__contact_request", "onboard__data_error","onboard__exemption", "onboard__expo", "onboard__image_processing_issues", "onboard__image_provider", "onboard__image_requirements", "onboard__li_initiative_overview", "onboard__other", "onboard__portal_navigation", "onboard__portal_navigation__timeline_questions", "onboard__portal_navigation__products_with_issues", "onboard__portal_navigation__products_ready_for_processing", "onboard__missing_products_", "onboard__registration_error", "onboard__submission_confirmation", "onboard__submission_portal_error", "onboard__third_party_questions", "onboard__updating_data");;
        label: "Onboard"
      }
      when: {
        sql:${custom_ticket_categories} IN("data_error", "feature_request/_product_feedback", "platform_downtime", "publish__bug__p2s2", "publish__bug__p2s3", "publish__bug__p3s2" ,"publish__bug__p3s3","data_request", "publish__other", "publish__unknown","user_permissions_and_admin", "training_gap");;
        label: "Publish"
      }
      when: {
        sql:${custom_ticket_categories} IN("explore__bug","explore__bug__p2s2", "explore__data_error", "explore__data_request", "explore__feature_request/_product_feedback", "explore__other", "explore__training_gap", "explore__user_permissions_and_admin");;
        label: "Explore"
      }
      when: {
        sql:${custom_ticket_categories} IN("capture__bug", "capture__data_error", "capture__data_request", "capture__feature_request/_product_feedback", "capture__image_issues", "capture__other", "capture__platform_downtime", "capture__training_gap", "capture__unknown", "capture__user_permissions_and_admin");;
        label: "Capture"
      }
      when: {
        sql:${custom_ticket_categories} IN("api","internal_requests");;
        label: "Other"
      }
    }
  }

  dimension: priority {
    group_label: "Basic Ticket Information"
    description: "The urgency with which the ticket should be addressed. Possible values: urgent, high, normal, low"
    type: string
    sql: case when LOWER(${TABLE}.priority) = 'low' then '2 - Low'
          when LOWER(${TABLE}.priority) = 'normal' then '3 - Normal'
          when LOWER(${TABLE}.priority) = 'high' then '4 - High'
          when LOWER(${TABLE}.priority) = 'urgent' then '5 - Urgent'
          when LOWER(${TABLE}.priority) is null then '1 - Not Assigned' end ;;
    html: {% if value == '1 - Not Assigned' %}
            <div style="color: black; background-color: grey; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% elsif value == '2 - Low' %}
            <div style="color: black; background-color: lightgreen; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% elsif value == '3 - Normal' %}
            <div style="color: black; background-color: yellow; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% elsif value == '4 - High' %}
            <div style="color: white; background-color: darkred; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% elsif value == '5 - Urgent' %}
            <div style="color: white; background-color: black; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% else %}
            <div style="color: black; background-color: blue; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% endif %}
    ;;
  }

  dimension: recipient {
    group_label: "Basic Ticket Information"
    description: "Recipient of a Zendesk ticket."
    type: string
    sql: ${TABLE}.recipient ;;
  }

  dimension: status {
    description: "The state of the ticket. Possible values: closed, deleted, hold, open, pending, and solved."
    type: string
    sql: ${TABLE}.status ;;
    group_label: "Ticket Progress"
  }

  dimension: subject {
    description: "Subject within a specific Zendesk ticket filled out by the ticket submitter."
    type: string
    sql: ${TABLE}.subject ;;
    group_label: "Basic Ticket Information"
  }

  dimension: type {
    description: "If applicable, Zendesk ticket type. Possible values: task, question, problem, and incident."
    type: string
    sql: ${TABLE}.`type` ;;
    group_label: "Basic Ticket Information"
  }

  dimension: url {
    description: "The URL which the Zendesk ticket was created on within the platform."
    type: string
    sql: ${TABLE}.url ;;
    group_label: "Basic Ticket Information"
  }

  dimension: via_channel {
    description: "Channel where the Zendesk ticket was submitted. Possible values: api, web, chat, email, and mobile."
    type: string
    sql: ${TABLE}.via_channel ;;
    group_label: "Basic Ticket Information"
  }

  dimension: via_source_from_title {
    type: string
    sql: ${TABLE}.via_source_from_title ;;
    group_label: "Basic Ticket Information"
  }

  dimension: via_source_rel {
    type: string
    sql: ${TABLE}.via_source_rel ;;
    group_label: "Basic Ticket Information"
  }

  # ----- date attributes ------
  dimension_group: created {
    group_label: "Status Dates"
    description: "Time at which the Zendesk ticket was created."
    type: time
    timeframes: [
      raw,
      day_of_week,
      hour_of_day,
      time,
      date,
      week,
      day_of_week_index,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: create_time_of_day_tier {
    group_label: "Status Dates"
    type: tier
    sql: ${created_hour_of_day} ;;
    tiers: [0, 4, 8, 12, 16, 20, 24]
    style: integer
  }

  dimension_group: last_updated {
    description: "Time since Zendesk ticket was updated."
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated_at ;;
  }

  dimension_group: due {
    group_label: "Ticket Progress"
    description: "Description of issue within Zendesk ticket."
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.due_at ;;
  }

  dimension: time_spent_last_update_min {
    label: "Time Spent Last Update Min"
    description: "Active minutes spent solving Zendesk ticket since last update."
    type: number
    sql: ${TABLE}.custom_time_spent_last_update_sec_/60;;
    group_label: "Time Tracking"
  }

  dimension: custom_total_time_spent_min {
    label: "Total Time Spent Min"
    description: "Active minutes spent solving Zendesk ticket, in total."
    type: number
    sql: ${TABLE}.custom_total_time_spent_sec_/60 ;;
    group_label: "Time Tracking"
  }

  # ----- looker fields -----
  dimension: is_resolved {
    type: yesno
    sql: ${status} = ${_TICKET_STATUS_CLOSED} ;;
    group_label: "Ticket Progress"
  }

  dimension: days_to_solve {
    type: number
    sql: 1.00 * DATE_DIFF(${ticket_history_facts.solved_date}, ${created_date}, DAY) ;;
    group_label: "Ticket Progress"
  }

  dimension: days_to_first_response {
    type: number
    sql: 1.00 * DATE_DIFF(${ticket_history_facts.first_response_date}, ${created_date}, DAY) ;;
    group_label: "Ticket Progress"
  }

  dimension: minutes_to_first_response {
    type: number
    sql: 1.00 * DATETIME_DIFF(EXTRACT(DATETIME FROM ${ticket_history_facts.first_response_raw}), EXTRACT(DATETIME FROM ${created_raw}), MINUTE) ;;
    group_label: "Ticket Progress"
  }

  dimension: hours_to_solve {
    type: number
    sql: 1.00 * TIMESTAMP_DIFF(${ticket_history_facts.solved_raw}, ${created_raw}, HOUR) ;;
    group_label: "Ticket Progress"
  }

  dimension: is_responded_to {
    type: yesno
    sql: ${minutes_to_first_response} is not null ;;
    group_label: "Ticket Progress"
  }

  dimension: days_since_updated {
    group_label: "Ticket Progress"
    type: number
    sql: 1.00 * DATE_DIFF(${_CURRENT_DATE}, ${last_updated_date}, DAY)  ;;
    html: {% if value > 60 %}
            <div style="color: white; background-color: darkred; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% else %}
            <div style="color: black; background-color: yellow; font-size:100%; text-align:center">{{ rendered_value }}</div>
          {% endif %}
      ;;
  }

  measure: avg_days_to_solve {
    type: average
    sql: ${days_to_solve} ;;
    value_format_name: decimal_2
    hidden: yes
  }

  dimension: weekdays_to_solve {
    description: "The number of days it took to solve the ticket not counting Saturday and Sunday."
    type: number
    sql:
      DATE_DIFF( ${ticket_history_facts.solved_date}, ${created_date}, DAY ) - ( FLOOR( DATE_DIFF( ${ticket_history_facts.solved_date}, ${created_date}, DAY ) / 7 ) * 2 )
      - CASE WHEN ${created_day_of_week_index} - ${ticket_history_facts.solved_day_of_week_index} IN (1, 2, 3, 4, 5) AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 2 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} != 6 AND ${ticket_history_facts.solved_day_of_week_index} = 6 THEN 1 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} = 6 AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 1 ELSE 0 END
      ;;
    value_format_name: decimal_0
    group_label: "Task Completion Time"
  }

  dimension: weekdays_to_solve_decimal {
    type: number
    description: "The number of weekday hours it took to solve a time divided by 24."
    sql: ROUND(${hours_to_solve_weekdays}/24,2) ;;

  }

  dimension: hours_to_solve_weekdays {
    description: "The number of hours it took to solve the ticket not counting Saturday and Sunday."
    type: number
    sql:
      TIMESTAMP_DIFF( ${ticket_history_facts.solved_raw}, ${created_raw}, HOUR ) - ( FLOOR( TIMESTAMP_DIFF( ${ticket_history_facts.solved_raw}, ${created_raw}, HOUR ) / 168 ) * 24 )
      - CASE WHEN ${created_day_of_week_index} - ${ticket_history_facts.solved_day_of_week_index} IN (1, 2, 3, 4, 5) AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 48 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} != 6 AND ${ticket_history_facts.solved_day_of_week_index} = 6 THEN 24 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} = 6 AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 24 ELSE 0 END
      ;;
    value_format_name: decimal_0
    group_label: "Task Completion Time"
  }

  dimension: custom_asana_ticket {
    label: "Asana Ticket"
    description: "If applicable, Asana ticket URL associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_asana_ticket ;;
    group_label: "Ticket Resolution"
  }

  dimension: custom_customer {
    label: "Customer"
    group_label: "Basic Ticket Information"
    description: "If applicable, customer associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_customer ;;
  }

  dimension: custom_data_type {
    label: "Data Type"
    description: "If applicable, data type associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_data_type ;;
    group_label: "Basic Ticket Information"
  }

  dimension: custom_expected_value {
    label: "Expected Value"
    description: "If applicable, expected value associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_expected_value ;;
    group_label: "Basic Ticket Information"
  }

  dimension: custom_feid_s_ {
    label: "FEIDs"
    description: "If applicable, feid's associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_feid_s_ ;;
    group_label: "Product Information"
  }

  dimension: custom_product {
    label: "Product"
    description: "If applicable, product associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_product ;;
    group_label: "Product Information"
  }

  dimension: custom_product_attribute {
    label: "Product Attribute"
    description: "If applicable, product attribute associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_product_attribute ;;
    group_label: "Product Information"
  }

  dimension: custom_product_description {
    label: "Product Description"
    description: "If applicable, product description associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_product_description ;;
    group_label: "Product Information"
  }

  dimension: custom_product_field {
    label: "Product Field"
    description: "If applicable, product field associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_product_field ;;
    group_label: "Product Information"
  }

  dimension: custom_product_type {
    label: "Product Type"
    description: "If applicable, product type associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_product_type ;;
    group_label: "Product Information"
  }

  dimension: custom_smart_label_type {
    label: "Smart Label Type"
    description: "Smart label type associated with the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_smart_label_type ;;
    group_label: "Product Information"
  }

  dimension: custom_solved_solely_by_css {
    label: "Solved Solely by CSS"
    description: "If applicable, if ticket was able to be solved solely by CSS."
    type: yesno
    sql: ${TABLE}.custom_solved_solely_by_css ;;
    group_label: "Ticket Resolution"
  }

  dimension:solved_by_department {
    group_label: "Ticket Resolution"
    description: "If applicable, if ticket was solved by either the Data, CSS, or Engineering team"
    case: {
      when: {
        sql: ${custom_asana_ticket} IS NOT NULL;;
        label: "Data"
      }
      when: {
        sql: ${custom_solved_solely_by_css}= TRUE;;
        label: "CSS"
      }
      when: {
        sql: ${created_date}<CAST("2018-03-01" AS DATE);;
        label: "Unknown"
        #Previous to March 1st, Label Insight used Freshdesk to answer tickets, which did not have department options
      }else: "Engineering"
    }
  }

  dimension: custom_upc_s_ {
    label: "UPCs"
    description: "If applicable, the UPC provided within the Zendesk ticket."
    type: string
    sql: ${TABLE}.custom_upc_s_ ;;
    group_label: "Product Information"
  }

  dimension: is_backlogged {
    type: yesno
    sql: ${status} = 'pending' ;;
    description: "If ticket is pending"
    group_label: "Ticket Progress"
  }

  dimension: is_new {
    type: yesno
    sql: ${status} = 'new' ;;
    description: "If ticket is new"
    group_label: "Ticket Progress"
  }

  dimension: is_open {
    type: yesno
    sql: ${status} = 'open' ;;
    description: "If ticket is open"
    group_label: "Ticket Progress"
  }

  ### THIS ASSUMES NO DISTINCTION BETWEEN SOLVED AND CLOSED
  dimension: is_solved {
    type: yesno
    sql: ${status} = 'solved' OR ${status} = 'closed' ;;
    group_label: "Ticket Progress"
  }


  dimension: subject_category {
    group_label: "Basic Ticket Information"
    sql: CASE
      WHEN ${subject} LIKE 'Chat%' THEN 'Chat'
      WHEN ${subject} LIKE 'Offline message%' THEN 'Offline Message'
      WHEN ${subject} LIKE 'Phone%' THEN 'Phone Call'
      ELSE 'Other'
      END
       ;;
  }

  measure: count_backlogged_tickets {
    group_label: "Status Counts"
    type: count
    filters: {
      field: is_backlogged
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: count_new_tickets {
    group_label: "Status Counts"
    type: count
    filters: {
      field: is_new
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: count_open_tickets {
    group_label: "Status Counts"
    type: count
    filters: {
      field: is_open
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: count_solved_tickets {
    group_label: "Status Counts"
    type: count
    filters: {
      field: is_solved
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: avg_minutes_to_response {
    type: average
    sql: ${minutes_to_first_response} ;;
    value_format_name: decimal_0
  }


  # ----- measures ------
  measure: count {
    group_label: "Distinct Ticket Count"
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      organization.name,
      custom_ticket_categories,
      subject,
      ticket_comment.body,
    ]
  }

  # ----- ID fields for joining  ------

  dimension: organization_id {
    type: number
    hidden: yes
    sql: ${TABLE}.organization_id ;;
  }

  dimension: problem_id {
    type: number
    hidden: yes
    sql: ${TABLE}.problem_id ;;
  }

  dimension: requester_id {
    description: "Recipient ID of an incoming Zendesk ticket."
    type: number
    hidden: yes
    sql: ${TABLE}.requester_id ;;
  }

  dimension: submitter_id {
    description: "The Submitter's ID associated with a Zendesk ticket."
    type: number
    hidden: yes
    sql: ${TABLE}.submitter_id ;;
  }

  dimension: ticket_form_id {
    description: "The ticket form ID associated with a Zendesk ticket."
    type: number
    hidden: yes
    sql: ${TABLE}.ticket_form_id ;;
  }

  dimension: via_source_from_id {
    type: number
    hidden: yes
    sql: ${TABLE}.via_source_from_id ;;
  }

  dimension: external_id {
    description: "External ID associated with a Zendesk ticket."
    type: string
    hidden: yes
    sql: ${TABLE}.external_id ;;
  }

  dimension: forum_topic_id {
    type: number
    hidden: yes
    sql: ${TABLE}.forum_topic_id ;;
  }

  dimension: group_id {
    description: "Group ID associated with a Zendesk ticket."
    type: number
    hidden: yes
    sql: ${TABLE}.group_id ;;
  }

  dimension: assignee_id {
    type: number
    hidden: yes
    sql: ${TABLE}.assignee_id ;;
  }

  dimension: brand_id {
    type: number
    hidden: yes
    sql: ${TABLE}.brand_id ;;
  }
}

view: user {
  extends: [_variables]
  sql_table_name: zendesk.user ;;
  extension: required

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: organization_id {
    description: "The unique identifier associated with a specific organization."
    type: number
    hidden: yes
    sql: ${TABLE}.organization_id ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    label: "{% if  _view._name == 'assignee' %} {{'Assignee Name'}} {% elsif _view._name == 'commenter' %} {{ 'Commenter Name'}} {% else %} {{ 'Requester Name'}} {% endif %} "
    type: string
    sql: ${TABLE}.name ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }
}

view: commenter {
  extends: [user]

  dimension: is_internal {
    type: yesno
    description: "Is an internal user?"
    sql: ${organization_id} = ${_INTERNAL_ORGANIZATION_ID} ;;
  }
}

view: assignee {
  extends: [user]

  dimension: name {
    label: "{% if  _view._name == 'assignee' %} {{'Assignee Name'}} {% elsif _view._name == 'commenter' %} {{ 'Commenter Name'}} {% else %} {{ 'Requester Name'}} {% endif %} "
    type: string
    sql: ${TABLE}.name ;;
    link: {
      label: "{{ value }}'s Dashboard"
      url: "https://{{ ticket._LOOKER_INSTANCE_DOMAIN._value }}.looker.com/dashboards/{{ ticket._ZENDESK_AGENT_PERFORMANCE_DASHBOARD_ID._value }}?Agent%20Name={{ value }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  dimension: chat_only {
    type: yesno
    sql: ${TABLE}.chat_only ;;
  }

  dimension: moderator {
    type: yesno
    sql: ${TABLE}.moderator ;;
  }

  dimension: shared_agent {
    type: yesno
    sql: ${TABLE}.shared_agent ;;
  }

  dimension: restricted_agent {
    type: yesno
    sql: ${TABLE}.restricted_agent ;;
  }

  # ----- agent comparison fields -----
  filter: agent_select {
    view_label: "Agent Comparisons"
    suggest_dimension: user.name
  }

  dimension: agent_comparitor {
    view_label: "Agent Comparisons"
    sql:
    CASE
      WHEN {% condition agent_select %} ${name} {% endcondition %}
      THEN ${name}
      ELSE CONCAT(' ', 'All Other Agents')
    END ;;
  }
}

view: requester {
  extends: [user]
  # The user who is asking for support through a ticket is the requester.

  dimension: locale {
    type: string
    sql: ${TABLE}.locale ;;
  }

  dimension_group: last_login {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_login_at ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}.notes ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}.role ;;
  }

  dimension: time_zone {
    type: string
    sql: ${TABLE}.time_zone ;;
  }

}

view: ticket_comment {
  view_label: "Ticket Comments"

  derived_table: {
    sql: SELECT *, row_number() over (partition by ticket_id order by created asc) as comment_sequence
      FROM zendesk.ticket_comment ;;
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: body {
    type: string
    sql: ${TABLE}.body ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created ;;
  }

  dimension: public {
    type: yesno
    description: "Can the customer see this comment?"
    sql: ${TABLE}.public ;;
  }

  dimension: ticket_id {
    type: number
    hidden: yes
    sql: ${TABLE}.ticket_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: facebook_comment {
    type: yesno
    sql: ${TABLE}.facebook_comment ;;
  }

  dimension: tweet {
    type: yesno
    sql: ${TABLE}.tweet ;;
  }

  dimension: voice_comment {
    type: yesno
    sql: ${TABLE}.voice_comment ;;
  }

  dimension: comment_sequence {
    type: number
    sql: ${TABLE}.comment_sequence ;;
  }

  measure: count {
    type: count
    drill_fields: [ticket.id, commenter.name, commenter.is_internal, public, created_time, comment_sequence, body]
  }
}

view: ticket_field_history {
  sql_table_name: zendesk.ticket_field_history ;;

  dimension: field_name {
    type: string
    sql: ${TABLE}.field_name ;;
  }

  dimension: ticket_id {
    type: number
    hidden: yes
    sql: ${TABLE}.ticket_id ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: organization {
  sql_table_name: zendesk.organization ;;

  # Just as agents can be segmented into groups in Zendesk Support, your customers (end-users)
  # can be segmented into organizations. You can manually assign customers to an organization
  # or automatically assign them to an organization by their email address domain. Organizations
  # can be used in business rules to route tickets to groups of agents or to send email notifications.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: group_id {
    type: number
    hidden: yes
    sql: ${TABLE}.group_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}.notes ;;
  }

  dimension: details {
    type: string
    sql: ${TABLE}.details ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

# ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      group.name,
      group.id,
      organization_member.count,
      organization_tag.count,
      ticket.count,
      user.count
    ]
  }
}

view: organization_member {
  sql_table_name: zendesk.organization_member ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: organization_id {
    type: number
    hidden: yes
    sql: ${TABLE}.organization_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }
}

view: group {
  view_label: "Organization"
  sql_table_name: zendesk.`group` ;;

  # When support requests arrive in Zendesk Support, they can be assigned to a Group.
  # Groups serve as the core element of ticket workflow; support agents are organized into
  # Groups and tickets can be assigned to a Group only, or to an assigned agent within a Group.
  # A ticket can never be assigned to an agent without also being assigned to a Group.

  dimension: name {
    label: "Group"
    type: string
    sql: ${TABLE}.name ;;
    description: "When support requests arrive in Zendesk Support, they can be assigned to a Group."
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
    hidden: yes
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}.deleted ;;
    hidden: yes
  }

  dimension_group: updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated_at ;;
    hidden: yes
  }
}

view: group_member {
  sql_table_name: zendesk.group_member ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: group_id {
    type: number
    hidden: yes
    sql: ${TABLE}.group_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }
}

view: brand {
  view_label: "Ticket"
  sql_table_name: zendesk.brand ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: name {
    label: "Brand"
    group_label: "Basic Ticket Information"
    type: string
    sql: ${TABLE}.name ;;
    description: "Brands are your customer-facing identities. They might represent multiple products or services, or they might literally be multiple brands owned and represented by your company."
  }
}

view: ticket_history_facts {
  view_label: "Ticket"
  derived_table: {
    sql: SELECT
          tfh.ticket_id
          ,IFNULL(tc.created, MAX(case when field_name = 'status' and value = 'solved' then updated else null end)) as first_response
          ,MAX(case when field_name = 'status' then updated else null end) AS last_updated_status
          ,MAX(case when field_name = 'assignee_id' then updated else null end) AS last_updated_by_assignee
          ,MAX(case when field_name = 'requester_id' then updated else null end) AS last_updated_by_requester
          ,MAX(case when field_name = 'status' and value = 'solved' then updated else null end) AS solved
          ,MAX(updated) AS updated
          ,MIN(case when field_name = 'assignee_id' then updated else null end) AS initially_assigned
          ,SUM(case when field_name = 'assignee_id' then 1 else 0 end) as number_of_assignee_changes
          ,count(distinct case when field_name = 'assignee_id' then value else null end) as number_of_distinct_assignees
          ,count(distinct case when field_name = 'group_id' then value else null end) as number_of_distinct_groups

      FROM zendesk.ticket_field_history as tfh
      LEFT JOIN (
          SELECT ticket_id, created, row_number() over (partition by ticket_id order by created asc) as comment_sequence
          FROM zendesk.ticket_comment
      ) tc on tc.ticket_id = tfh.ticket_id and tc.comment_sequence = 2
      GROUP BY ticket_id, tc.created ;;
  }

  dimension_group: first_response {
    group_label: "Status Dates"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.first_response ;;
  }

  dimension: ticket_id {
    type: number
    sql: ${TABLE}.ticket_id ;;
    hidden: yes
    primary_key: yes
  }

  dimension_group: last_updated_status {
    group_label: "Status Dates"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_updated_status ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated ;;
    hidden: yes
    # why is this not = to the field on ticket on some occasions? should be redundant.
    group_label: "Status Dates"
  }

  dimension_group: last_updated_by_assignee {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_updated_by_assignee ;;
    group_label: "Status Dates"
  }

  dimension_group: last_updated_by_requester {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.last_updated_by_requester ;;
    group_label: "Status Dates"
  }

  dimension_group: solved {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      day_of_week_index,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.solved ;;
    group_label: "Status Dates"
  }

  dimension_group: initially_assigned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.initially_assigned ;;
    group_label: "Status Dates"
  }

  dimension: number_of_assignee_changes {
    hidden: yes
    type: number
    sql: ${TABLE}.number_of_assignee_changes ;;
    description: "Number of times the assignee changed for a ticket (including initial assignemnt)"
  }

  dimension: number_of_distinct_assignees {
    hidden: yes
    type: number
    sql: ${TABLE}.number_of_distinct_assignees ;;
    description: "Number of distinct assignees for a ticket"
  }

  dimension: number_of_distinct_groups {
    hidden: yes
    type: number
    sql: ${TABLE}.number_of_distinct_groups ;;
    description: "Number of distinct groups for a ticket"
  }

  measure: total_number_of_distinct_assignees {
    group_label: "Distinct Assignees"
    type: sum
    sql: ${number_of_distinct_assignees} ;;
  }

  measure: average_number_of_distinct_assignees {
    group_label: "Distinct Assignees"
    type: average
    sql: ${number_of_distinct_assignees} ;;
    value_format_name: decimal_2
  }

  measure: median_number_of_distinct_assignees {
    group_label: "Distinct Assignees"
    type: median
    sql: ${number_of_distinct_assignees} ;;
  }

  measure: total_number_of_assignee_changes {
    group_label: "Assignee Changes"
    type: sum
    sql: ${number_of_assignee_changes} ;;
  }

  measure: avg_number_of_assignee_changes {
    group_label: "Assignee Changes"
    type: average
    sql: ${number_of_assignee_changes} ;;
    value_format_name: decimal_2
  }

  measure: median_number_of_assignee_changes {
    group_label: "Assignee Changes"
    type: median
    sql: ${number_of_assignee_changes} ;;
  }

  measure: total_number_of_distinct_groups {
    group_label: "Distinct Groups"
    type: sum
    sql: ${number_of_distinct_groups} ;;
  }

  measure: avg_number_of_distinct_groups {
    group_label: "Distinct Groups"
    type: average
    sql: ${number_of_distinct_groups} ;;
    value_format_name: decimal_2
  }

  measure: median_number_of_distinct_groups {
    group_label: "Distinct Groups"
    type: median
    sql: ${number_of_distinct_groups} ;;
  }
}

view: number_of_reopens {
  view_label: "Ticket"
  derived_table: {
    sql:  WITH grouped_ticket_status_history AS (
            SELECT *
            FROM zendesk.ticket_field_history
            WHERE field_name = 'status'
            ORDER BY ticket_id, updated
         ),
         statuses AS (
            SELECT
                ticket_id,
                LAG(ticket_id, 1, 0) OVER(ORDER BY ticket_id, updated) AS prev_ticket_id,
                value AS status,
                LAG(value, 1, 'new') OVER(ORDER BY ticket_id, updated) AS prev_status
            FROM grouped_ticket_status_history
         )
         SELECT
             DISTINCT ticket_id,
             COUNT(ticket_id) AS number_of_reopens
         FROM statuses
         WHERE ticket_id = prev_ticket_id AND prev_status = 'solved' AND status = 'open'
         GROUP BY ticket_id ;;
  }

  dimension: ticket_id {
    type: number
    sql: ${TABLE}.ticket_id ;;
    hidden: yes
    primary_key: yes
  }

  dimension: number_of_reopens {
    group_label: "Ticket Progress"
    type: number
    sql: ${TABLE}.number_of_reopens ;;
    description: "Number of times the ticket was reopened"
  }

  measure: total_number_of_reopens {
    group_label: "Reopens"
    type: sum
    sql: ${number_of_reopens} ;;
  }

  measure: avg_number_of_reopens {
    group_label: "Reopens"
    type: average
    sql: ${number_of_reopens} ;;
    value_format_name: decimal_2
  }

  measure: median_number_of_reopens {
    group_label: "Reopens"
    type: median
    sql: ${number_of_reopens} ;;
  }
}

# view: ticket_comment_facts {}

view: ticket_assignee_facts {
  view_label: "Assignee"
  derived_table: {
    sql: SELECT
        assignee_id
        , count(*) as lifetime_tickets
        , min(created_at) as first_ticket
        , max(created_at) as latest_ticket
        , 1.0 * COUNT(*) / NULLIF(DATE_DIFF(CURRENT_DATE, MIN(EXTRACT(date from created_at)), day), 0) AS avg_tickets_per_day
      FROM zendesk.ticket
      GROUP BY 1
       ;;
  }

  dimension: assignee_id {
    primary_key: yes
    sql: ${TABLE}.assignee_id ;;
    description: "Unique ID for the assignee of the Zendesk ticket."
    hidden: yes
  }

  dimension: lifetime_tickets {
    type: number
    value_format_name: id
    sql: ${TABLE}.lifetime_tickets ;;
  }

  dimension_group: first_ticket {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.first_ticket ;;
  }

  dimension_group: latest_ticket {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.latest_ticket ;;
  }

  dimension: avg_tickets_per_day {
    type: number
    sql: ${TABLE}.avg_tickets_per_day ;;
  }

  measure: total_lifetime_tickets {
    type: sum
    sql: ${lifetime_tickets} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [assignee_id, lifetime_tickets, first_ticket_time, latest_ticket_time, avg_tickets_per_day]
  }
}
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
