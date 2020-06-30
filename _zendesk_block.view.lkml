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

  dimension: bug_severity {
    group_label: "Customer Facing SLAs"
    description: "Bug & Data Issue Resolution Severity Level."
    type: string
    sql: ${TABLE}.custom_bug_severity ;;
  }

  dimension: response_target_time {
    group_label: "Customer Facing SLAs"
    description: "Target Bug & Data Issue Resolution Timeline"
    type: string
    sql:
      CASE
        WHEN ${bug_severity} like '%s1%' THEN '1 Business Day'
        WHEN ${bug_severity} like '%s2%' THEN '2 Business Days'
        WHEN ${bug_severity} like '%s3%' THEN '10 Business Days'
        WHEN ${bug_severity} like '%s4%' THEN '20 Business Days'
        ELSE NULL
      END
    ;;
  }

  dimension: over_bug_severity_response_sla {
    label: "Over Bug Severity SLA?"
    group_label: "Customer Facing SLAs"
    type: yesno
    sql:
    (${is_solved} = TRUE AND ${ticket_history_facts.solved_raw} > ${sla_due_raw})
    OR
    (${is_solved} = FALSE AND CURRENT_TIMESTAMP() > ${sla_due_raw})
    ;;
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
        sql: ${custom_ticket_categories}= "api" ;;
        label:  "API"
      }
      when: {
        sql: ${custom_ticket_categories}= "api__unknown";;
        label: "API Unknown"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__bug__p1s1";;
      label: "Capture Bug S1-Blocker"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__bug__p1s2" OR ${custom_ticket_categories}= "capture__bug__p2s2" OR ${custom_ticket_categories}= "capture__bug__p3s2";;
        label: "Capture Bug S2-Critical"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__bug__p1s3" OR ${custom_ticket_categories}= "capture__bug__p2s3" OR ${custom_ticket_categories}= "capture__bug" OR ${custom_ticket_categories}= "capture__bug__p3s3";;
        label: "Capture Bug S3-Major"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__bug__p1s4";;
        label: "Capture Bug S4-Minor"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__bug__p1s5";;
        label: "Capture Bug S5-Cosmetic"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__data_error";;
        label: "Capture - Data Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__data_request";;
        label: "Capture - Data Request"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__feature_request/_product_feedback";;
        label: "Capture - Feature Request/ Product Feedback"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__image_issues";;
        label: "Capture - Image Issues"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__platform_downtime";;
        label: "Capture - Platform Downtime"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__training_gap";;
        label: "Capture - Training Gap"
      }
      when: {
        sql: ${custom_ticket_categories}= "capture__other" OR ${custom_ticket_categories}= "capture__unknown";;
        label: "Capture - Other"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__attribute_error";;
        label: "Explore - Attribute Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__bug__p1s1";;
        label: "Explore Bug S1-Blocker"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__bug__p1s2" OR ${custom_ticket_categories}= "explore__bug__p2s2";;
        label: "Explore Bug S2-Critical"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__bug__p1s3" OR ${custom_ticket_categories}= "explore__bug" OR ${custom_ticket_categories}= "explore__bug__p3s3";;
        label: "Explore Bug S3-Major"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__bug__p1s4" ;;
        label: "Explore Bug S4-Minor"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__bug__p1s5";;
        label: "Explore Bug S5-Cosmetic"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore___data_currency";;
        label: "Explore - Data Currency"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__data_error";;
        label: "Explore - Data Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__data_request";;
        label: "Explore - Data Request"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__feature_request/_product_feedback";;
        label: "Explore - Feature Request/ Product Feedback"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__platform_downtime";;
        label: "Explore - Platform Downtime"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__training_gap";;
        label: "Explore - Training Gap"
      }
      when: {
        sql: ${custom_ticket_categories}= "explore__other" OR ${custom_ticket_categories}= "explore__unknown";;
        label: "Explore - Other"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__account_error" ;;
        label: "Onboard - Account Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__bug__s1_-_blocker";;
        label: "Onboard Bug S1-Blocker"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__bug__s2_-_critical";;
        label: "Onboard Bug S2-Critical"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__bug__s3_-_major" OR ${custom_ticket_categories}= "onboard__bug";;
        label: "Onboard Bug S3-Major"
      }
      when: {
        sql: ${custom_ticket_categories} = "onboard__bug__s4_-_minor";;
        label: "Onboard Bug S4-Minor"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__bug__s5_-_cosmetic";;
        label: "Onboard Bug S5-Cosmetic"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__change_of_contact" OR ${custom_ticket_categories} = "onboard__contact_request";;
        label: "Onboard - Change of Contact"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__deleting_images_";;
        label: "Onboard - Deleting Images"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__data_error";;
        label: "Onboard - Data Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__exemption";;
        label: "Onboard - Exemption"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__expo";;
        label: "Onboard - Expo"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__feature_request/_product_feedback";;
        label: "Onboard - Feature Request/ Product Feedback"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_processing_issues";;
        label: "Onboard - Image Processing Issues"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_provider";;
        label: "Onboard - Image Provider"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__image_requirements";;
        label: "Onboard - Image Requirements"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__li_initiative_overview";;
        label: "Onboard - LI Initiative Overview"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard___missing_products_" ;;
        label:  "Onboard - Missing Product"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__other" OR ${custom_ticket_categories}= "onboard__unknown" OR ${custom_ticket_categories}= "onboard__check_in";;
        label: "Onboard - Other"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__portal_navigation";;
        label: "Onboard - Portal Navigation"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__portal_navigation__timeline_questions" ;;
        label: "Onboard - Portal Navigation - Timeline Questions"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__portal_navigation__products_with_issues" ;;
        label: "Onboard - Portal Navigation - Products with Issues"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__portal_navigation__processing/_delay" ;;
        label: "Onboard - Portal Navigation - Processing/ Delay"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__portal_navigation__products_ready_for_processing" ;;
        label: "Onboard - Portal Navigation - Products Ready for Processing"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboarding__upc_request__discontinued_upcs";;
        label: "Onboard - Requested Products - UPC Request - Discontinued UPCs"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboarding__upc_request__inaccurate_upcs" ;;
        label: "Onboard - Requested Products - UPC Request - Inaccurate UPCs"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboarding__upc_request__overview/explanation" ;;
        label: "Onboard - Requested Products- UPC Request - Overview/Explanation"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__requested_products__products_previously_onboarded_" ;;
        label: "Onboard - Requested Products- Products Previously Onboarded"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__registration_error";;
        label: "Onboard - Registration Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__submission_portal_error";;
        label: "Onboard - Submission Portal Error"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__submission_confirmation";;
        label: "Onboard - Submission Confirmation"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__third_party_questions";;
        label: "Onboard - Third Party Questions"
      }
      when: {
        sql: ${custom_ticket_categories}= "onboard__updating_data" ;;
        label: "Onboard - Updating Data"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__delete_product_requested" ;;
        label: "Expo - Delete Product Requested"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__wrong_products_showing" ;;
        label: "Expo - Wrong Products Showing"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__marketing_images_not_showing" ;;
        label: "Expo - Marketing Images Not Showing"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__timeline_questions" ;;
        label: "Expo - Timeline Questions"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__wrong_booth_number" ;;
        label: "Expo - Wrong Booth Number"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__wrong_company_information" ;;
        label: "Expo - Wrong Company Information"
      }
      when: {
        sql: ${custom_ticket_categories}= "informa__transfer_products_from_last_show" ;;
        label: "Expo - Transfer Products from Last Show"
      }
      when: {
        sql: ${custom_ticket_categories}= "internal_requests";;
        label: "Internal Requests"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__bug__p1s1" OR ${custom_ticket_categories} = "publish__bug__p2s1";;
        label: "Publish Bug S1-Blocker"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__bug__p1s2" OR ${custom_ticket_categories} = "publish__bug__p2s2" OR ${custom_ticket_categories} = "publish__bug__p3s2";;
        label: "Publish Bug S2-Critical"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__bug__p1s3" OR ${custom_ticket_categories} = "publish__bug__p4s3" OR ${custom_ticket_categories} = "publish__bug__p2s3" OR ${custom_ticket_categories} = "publish__bug__p3s3" ;;
        label: "Publish Bug S3-Major"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__bug__p1s4" OR ${custom_ticket_categories} = "publish__bug__p2s4" OR ${custom_ticket_categories} = "publish__bug__p3s4" OR ${custom_ticket_categories} = "bug";;
        label: "Publish Bug S4-Minor"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__bug__p1s5";;
        label: "Publish Bug S5-Cosmetic"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__data_error" OR ${custom_ticket_categories} = "data_error";;
        label: "Publish - Data Error"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__data_request" OR ${custom_ticket_categories} = "data_request";;
        label: "Publish - Data Request"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__feature_request/_product_feedback" OR ${custom_ticket_categories}= "feature_request/_product_feedback";;
        label: "Publish - Feature Request/ Product Feedback"
      }
      when: {
        sql: ${custom_ticket_categories} = "platform_downtime";;
        label: "Publish - Platform Downtime"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__training_gap" OR ${custom_ticket_categories}= "training_gap";;
        label: "Publish - Training Gap"
      }
      when: {
        sql: ${custom_ticket_categories} = "publish__other" OR ${custom_ticket_categories}= "publish__unknown";;
        label: "Publish - Other"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__incorrect_thumbnail" ;;
        label: "Snap Issues - Incorrect Thumbnail"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__marketing_images_out_of_order" ;;
        label: "Snap Issues - Marketing Images out of Order"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__missing_spin_image_in_publish" ;;
        label: "Snap Issues - Missing Spin Image in Publish"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__color_distortion" ;;
        label: "Snap Issues - Color Distortion"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__blurry_image" ;;
        label: "Snap Issues - Blurry Image"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__missing_image" OR ${custom_ticket_categories}= "snap_issues";;
        label: "Snap Issues - Missing Image"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__background/_props_not_removed" ;;
        label: "Snap Issues - Background - Props not Removed"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__poor_propping" ;;
        label: "Snap Issues - Poor Propping"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__update_shooting_angle" ;;
        label: "Snap Issues - Update Shooting Angle"
      }
      when: {
        sql: ${custom_ticket_categories}= "snap_issues__packaging_flaws___imperfections" ;;
        label: "Snap Issues - Packaging Flaws & Imperfections"
      }
      when: {
        sql: ${custom_ticket_categories}= "admin__user_permissions__product_assignments" OR ${custom_ticket_categories}= "capture__user_permissions_and_admin" OR ${custom_ticket_categories}= "explore__user_permissions_and_admin" OR ${custom_ticket_categories}= "user_permissions_and_admin" OR ${custom_ticket_categories}= "admin__user_permissions";;
        label: "Admin - User Permissions & Product Assignments"
      }
      when: {
        sql: ${custom_ticket_categories}= "admin__org_group_configuration";;
        label: "Admin - Organization Configuration"
      }
      when: {
        sql: ${custom_ticket_categories}= "admin__app_shell";;
        label: "Admin- App Shell"
      }
      when: {
        sql: ${custom_ticket_categories} = "admin__bug__s1_-_blocker";;
        label: "Admin Bug S1-Blocker"
      }
      when: {
        sql: ${custom_ticket_categories} = "admin__bug__s2_-_critical";;
        label: "Admin Bug S2-Critical"
      }
      when: {
        sql: ${custom_ticket_categories} = "admin__bug__s3_-_major";;
        label: "Admin Bug S3-Major"
      }
      when: {
        sql: ${custom_ticket_categories} = "admin__bug__s4_-_minor";;
        label: "Admin Bug S4-Minor"
      }
      when: {
        sql: ${custom_ticket_categories} = "admin__bug__s5_-_cosmetic";;
        label: "Admin Bug S5-Cosmetic"
      }
      when: {
        sql: ${custom_ticket_categories}= "admin__help_center___widget_" ;;
        label: "Admin - Help Center Widget"
      }
      when: {
        sql: ${custom_ticket_categories}= "admin__other" OR ${custom_ticket_categories}= "admin__product_assignments_";;
        label: "Admin - Other"
      }
    }
  }

  dimension: Platform {
    group_label: "Basic Ticket Information"
    description: "Custom ticket categories grouped by different LI platform"
    case: {
      when: {
        sql:${custom_ticket_categories} like "%publish%" OR ${custom_ticket_categories} IN("data_error", "feature_request/_product_feedback", "data_request", "training_gap", "platform_downtime");;
        label: "Publish"
      }
      when: {
        sql:${custom_ticket_categories} like "%explore%";;
        label: "Explore"
      }
      when: {
        sql:${custom_ticket_categories} like "%capture%";;
        label: "Capture"
      }
      when: {
        sql:${custom_ticket_categories} like "%admin%";;
        label: "Admin"
      }
      when: {
        sql:${custom_ticket_categories} IN("api","internal_requests");;
        label: "API/Internal Requests"
      }
      when: {
        sql:${custom_ticket_categories} like "%snap%";;
        label: "Snap"
      }
      when: {
        sql:${custom_ticket_categories} like "%onboard%";;
        label: "Onboard"
      }
      when: {
        sql: ${custom_ticket_categories} like "%informa" ;;
        label: "Expo"
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
      time_of_day,
      date,
      week,
      day_of_week_index,
      month,
      quarter,
      year
    ]
    sql: TIMESTAMP(DATETIME(${TABLE}.created_at, "America/Chicago")) ;;
  }

  dimension: create_time_of_day_tier {
    group_label: "Status Dates"
    type: tier
    sql: ${created_hour_of_day} ;;
    tiers: [0, 4, 8, 12, 16, 20, 24]
    style: integer
  }

  dimension_group: last_updated {
    group_label: "Status Dates"
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
    sql: TIMESTAMP(DATETIME(${TABLE}.updated_at, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.due_at, "America/Chicago")) ;;
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

  dimension_group: created_start_of_business {
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
    sql:
      CASE
        -- M-Th after 5pm = next day 9am
        WHEN
          ${created_day_of_week_index} IN (0,1,2,3) AND ${created_hour_of_day} > 16
        THEN
          TIMESTAMP( CONCAT( SAFE_CAST( DATE_ADD( ${created_date}, INTERVAL 1 DAY) AS STRING), " 09:00:00") )
        -- M-F before 9am = same day 9am
        WHEN
          ${created_day_of_week_index} IN (0,1,2,3,4) AND ${created_hour_of_day} < 9
        THEN
          TIMESTAMP( CONCAT( SAFE_CAST(${created_date} AS STRING), " 09:00:00") )
        -- F after 5pm and Sat = next Monday 9am
        WHEN
          (${created_day_of_week_index} IN (4) AND ${created_hour_of_day} > 16) OR ${created_day_of_week_index} IN (5,6)
        THEN
          TIMESTAMP( CONCAT( SAFE_CAST( DATE_ADD( ${created_date}, INTERVAL 7-${created_day_of_week_index} DAY) AS STRING), " 09:00:00") )
        ELSE
          ${created_raw}
      END
    ;;
    hidden: yes
    group_label: "Customer Facing SLAs"
  }

  dimension_group: sla_due {
    label: "SLA Due"
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
    sql:
      CASE
        WHEN
          ${response_target_time} = '1 Business Day'
        THEN
          TIMESTAMP_ADD( ${created_raw}, INTERVAL 8 HOUR)
        WHEN
          ${response_target_time} = '2 Business Days'
          AND ${created_start_of_business_day_of_week_index} IN (0,1,2)
        THEN
          TIMESTAMP_ADD( ${created_start_of_business_raw}, INTERVAL 2 DAY)
        WHEN
          ${response_target_time} = '2 Business Days'
          AND ${created_start_of_business_day_of_week_index} IN (3,4)
        THEN
          TIMESTAMP_ADD( ${created_start_of_business_raw}, INTERVAL 7-${created_start_of_business_day_of_week_index} DAY)
        WHEN
          ${response_target_time} = '10 Business Days'
        THEN
          TIMESTAMP_ADD( ${created_start_of_business_raw}, INTERVAL 14 DAY)
        WHEN
          ${response_target_time} = '20 Business Days'
        THEN
          TIMESTAMP_ADD( ${created_start_of_business_raw}, INTERVAL 28 DAY)
        ELSE
          NULL
      END
    ;;
    group_label: "Customer Facing SLAs"
  }

  dimension: weekdays_to_solve {
    description: "The number of days it took to solve the ticket not counting Saturday and Sunday."
    group_label: "Status Dates"
    type: number
    sql:
      DATE_DIFF( ${ticket_history_facts.solved_date}, ${created_date}, DAY ) - ( FLOOR( DATE_DIFF( ${ticket_history_facts.solved_date}, ${created_date}, DAY ) / 7 ) * 2 )
      - CASE WHEN ${created_day_of_week_index} - ${ticket_history_facts.solved_day_of_week_index} IN (1, 2, 3, 4, 5) AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 2 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} != 6 AND ${ticket_history_facts.solved_day_of_week_index} = 6 THEN 1 ELSE 0 END
      - CASE WHEN ${created_day_of_week_index} = 6 AND ${ticket_history_facts.solved_day_of_week_index} != 6 THEN 1 ELSE 0 END
      ;;
  }

  # dimension_group: start {
  #   type: time
  #   timeframes: [raw, date, time, day_of_week_index, week_of_year, hour_of_day, hour, minute, quarter, time_of_day]
  #   sql: ${TABLE}.created;;
  # }

  # dimension_group: stop {
  #   type: time
  #   timeframes: [raw, date, time, day_of_week_index, week_of_year, hour_of_day, hour, minute, quarter, time_of_day]
  #   sql: ${ticket_history_facts.solved_date} ;;
  # }

  # dimension: work_days {
  #   sql: DATEDIFF(DAY, ${created_date}, ${ticket_history_facts.solved_date}) - ((FLOOR(DATEDIFF(DAY, ${created_date}, ${ticket_history_facts.solved_date}) / 7) * 2) +
  #         CASE WHEN ${created_day_of_week_index}-${ticket_history_facts.solved_day_of_week_index} IN (1, 2, 3, 4, 5) AND ${ticket_history_facts.solved_day_of_week_index} != 0
  #         THEN 2 ELSE 0 END + CASE WHEN ${created_day_of_week_index} != 0 AND ${ticket_history_facts.solved_day_of_week_index} = 0 THEN 1 ELSE 0 END +
  #         CASE WHEN ${created_day_of_week_index} = 0 AND ${ticket_history_facts.solved_day_of_week_index} != 0 THEN 1 ELSE 0 END) ;;
  # }

  dimension: business_hours {
    hidden: yes
    type:  number
    sql: CASE
          WHEN ${created_day_of_week_index} IN (5, 6) AND ${ticket_history_facts.solved_day_of_week_index} IN (5, 6)
            THEN ${weekdays_to_solve}*8
          WHEN ${created_day_of_week_index} IN (5, 6) AND ${ticket_history_facts.solved_day_of_week_index} NOT IN (5, 6)
            THEN (${weekdays_to_solve}*8) + CASE WHEN ${ticket_history_facts.solved_hour_of_day} < 9 THEN 0
                                         WHEN ${ticket_history_facts.solved_hour_of_day} >=9 AND ${ticket_history_facts.solved_hour_of_day} <= 17 THEN ${ticket_history_facts.solved_hour_of_day}-9
                                         ELSE 8
                                         END
          WHEN ${created_day_of_week_index} NOT IN (5, 6) AND ${ticket_history_facts.solved_day_of_week_index} IN (5, 6)
            THEN ((${weekdays_to_solve} - 1)*8) + CASE WHEN ${created_hour_of_day} < 9 THEN 8
                                             WHEN ${created_hour_of_day} >= 9 AND ${created_hour_of_day} <= 17 THEN 17-${created_hour_of_day}
                                             ELSE 0
                                             END
          ELSE ((${weekdays_to_solve} - 1)*8) + CASE WHEN ${created_hour_of_day} < 9 THEN 8
                                           WHEN ${created_hour_of_day} >= 9 AND ${created_hour_of_day} <= 17 THEN 17-${created_hour_of_day}
                                           ELSE 0
                                           END +
                                      CASE WHEN ${ticket_history_facts.solved_hour_of_day} < 9 THEN 0
                                           WHEN ${ticket_history_facts.solved_hour_of_day} >=9 AND ${ticket_history_facts.solved_hour_of_day} <= 17 THEN ${ticket_history_facts.solved_hour_of_day}-9
                                           ELSE 8
                                           END
          END;;
  }

  measure: average_business_hours {
    type: average
    sql: ${business_hours} ;;
    value_format_name: decimal_2
  }

  measure: average_business_days {
    type: average
    sql: ${business_hours}/8 ;;
    value_format_name: decimal_2
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

  # ----- measures ------
  measure: avg_days_to_solve {
    type: average
    sql: ${days_to_solve} ;;
    value_format_name: decimal_2
    hidden: yes
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

  measure: count {
    label: "Count Distinct Tickets"
    group_label: "Distinct Ticket Count"
    type: count
    drill_fields: [detail*]
  }

  measure: count_distinct_customer_sla_tickets {
    label: "Count Distinct Tickets with Customer SLAs"
    group_label: "Distinct Ticket Count"
    type: count
    filters: [
      response_target_time: "-null"
    ]
    drill_fields: [detail*]
  }

  measure: count_distinct_tickets_solved_under_sla {
    label: "Count Distinct Tickets Solved Under SLA"
    group_label: "Distinct Ticket Count"
    type: count
    filters: [
      over_bug_severity_response_sla: "No",
      is_solved: "Yes",
      response_target_time: "-null"
    ]
    drill_fields: [detail*, over_bug_severity_response_sla]
  }

  measure: percentage_of_tickets_under_sla {
    label: "Percentage Tickets Solved Under SLA"
    type: number
    sql: SAFE_DIVIDE(${count_distinct_tickets_solved_under_sla}, ${count_distinct_customer_sla_tickets}) ;;
    drill_fields: [detail*, over_bug_severity_response_sla]
    value_format_name: percent_2
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

view: zendesk_user {
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
    label: "Count Distinct Users"
    description: "A number of distinct Zendesk users, including assignee, commenter, and requester."
    type: count
    drill_fields: [detail*]
  }
}

view: commenter {
  extends: [zendesk_user]

  dimension: is_internal {
    type: yesno
    description: "Is an internal user?"
    sql: ${organization_id} = ${_INTERNAL_ORGANIZATION_ID} ;;
  }
}

view: assignee {
  extends: [zendesk_user]

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
  extends: [zendesk_user]
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
    sql: TIMESTAMP(DATETIME(${TABLE}.last_login_at, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.created, "America/Chicago")) ;;
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
    label: "Count Distinct Ticket Comments"
    description: "Number of distinct Zendesk ticket comments."
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
    sql: TIMESTAMP(DATETIME(${TABLE}.updated, "America/Chicago")) ;;
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
    label: "Count Distinct Organizations"
    description: "Number of distinct organizations."
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
    sql: TIMESTAMP(DATETIME(${TABLE}.created_at, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.updated_at, "America/Chicago")) ;;
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
          ,SUM(case when field_name = '360043017774' and length(value) > 0 then 1 else 0 end) as number_of_bug_severity_changes
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
      day_of_week,
      hour_of_day,
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: TIMESTAMP(DATETIME(${TABLE}.first_response, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.last_updated_status, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.updated, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.last_updated_by_assignee, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.last_updated_by_requester, "America/Chicago")) ;;
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
      hour_of_day,
      month,
      quarter,
      year
    ]
    sql: TIMESTAMP(DATETIME(${TABLE}.solved, "America/Chicago")) ;;
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
    sql: TIMESTAMP(DATETIME(${TABLE}.initially_assigned, "America/Chicago")) ;;
    group_label: "Status Dates"
  }

  dimension: number_of_assignee_changes {
    hidden: yes
    type: number
    sql: ${TABLE}.number_of_assignee_changes ;;
    description: "Number of times the assignee changed for a ticket (including initial assignemnt)"
  }

  dimension: number_of_bug_severity_changes {
    hidden: yes
    type: number
    sql: ${TABLE}.number_of_bug_severity_changes ;;
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

  measure: count_correct_triage {
    group_label: "Bug Triage Metrics"
    type: count_distinct
    sql: CASE WHEN ${number_of_bug_severity_changes} = 1 THEN ${ticket_id} ELSE NULL END;;
  }

  measure: count_incorrect_triage {
    group_label: "Bug Triage Metrics"
    type: count_distinct
    sql: CASE WHEN ${number_of_bug_severity_changes} > 1 THEN ${ticket_id} ELSE NULL END;;
  }

  measure: triage_accuracy {
    group_label: "Bug Triage Metrics"
    type: number
    sql: SAFE_DIVIDE( ${count_correct_triage}, ${count_correct_triage} + ${count_incorrect_triage} ) ;;
    value_format_name: percent_2
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
    sql: TIMESTAMP(DATETIME(${TABLE}.first_ticket, "America/Chicago")) ;;
  }

  dimension_group: latest_ticket {
    type: time
    timeframes: [time, date, week, month]
    sql: TIMESTAMP(DATETIME(${TABLE}.latest_ticket, "America/Chicago")) ;;
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

view: ticket_tags {
  view_label: "Ticket"
  sql_table_name: zendesk.ticket_tag ;;

# ----- Dimensions -----
  dimension: tag {
    group_label: "Basic Ticket Information"
    description: "A label given to a zendesk ticket. Anything made into a jira ticket automatically has \"jira_escalated\". Tickets can have multiple tags."
    type: string
    sql: ${TABLE}.tag ;;
}
  dimension: ticket_id {
    type: number
    sql: ${TABLE}.ticket_id ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}._fivetran_synced ;;
    hidden: yes
  }

# ----- Measures -----
  measure: tag_list {
    description: "A comma seperated list of all tags associated with this product."
    type: list
    list_field: tag
  }
}

view: zendesk_satisfaction_rating {
  sql_table_name: zendesk.satisfaction_rating ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}._fivetran_synced ;;
    hidden: yes
  }

  dimension: ticket_id {
    type: number
    sql: ${TABLE}.ticket_id ;;
    hidden: yes
  }

  dimension_group: created_at {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at ;;
  }

  dimension: comment {
    type: string
    sql: ${TABLE}.comment ;;
  }

  dimension: score {
    description: "offered, unoffered, good, or bad"
    type: string
    sql: ${TABLE}.score ;;
  }

  dimension: reason {
    type: string
    sql: ${TABLE}.reason ;;
  }

  measure: count_distinct_offered_satisfaction_rating {
    type: count
    filters: [
      score: "offered"
    ]
    hidden: yes
  }
  measure: count_distinct_unoffered_satisfaction_rating {
    type: count
    filters: [
      score: "unoffered"
    ]
    hidden: yes
  }
  measure: count_distinct_good_satisfaction_rating {
    label: "Total Good Ratings"
    type: count
    filters: [
      score: "good"
    ]
  }
  measure: count_distinct_bad_satisfaction_rating {
    label: "Total Bad Ratings"
    type: count
    filters: [
      score: "bad"
    ]
  }
  measure: count_distinct_satisfaction_rating_responses {
    label: "Total Ratings"
    type: number
    sql: ${count_distinct_good_satisfaction_rating} + ${count_distinct_bad_satisfaction_rating} ;;
  }
  measure: satisfaction_response_rate {
    type: number
    sql: SAFE_DIVIDE( ${count_distinct_satisfaction_rating_responses}, ${count_distinct_offered_satisfaction_rating} + ${count_distinct_satisfaction_rating_responses} ) ;;
    value_format_name: percent_2
  }
  measure: satisfaction_score {
    type: number
    sql: SAFE_DIVIDE( ${count_distinct_good_satisfaction_rating}, ${count_distinct_satisfaction_rating_responses} ) ;;
    value_format_name: percent_2
  }

}

view: jira_zendesk_ids {
  derived_table: {
    sql:
    SELECT DISTINCT
      CONCAT(SAFE_CAST(id AS STRING), '-', SAFE_CAST(zendesk_ticket_id AS STRING)) as pkey,
      SAFE_CAST(id AS INT64) as jira_id,
      SAFE_CAST(zendesk_ticket_id AS INT64) as zendesk_ticket_id
    FROM jira.issue, UNNEST(SPLIT(zendesk_ticket_ids)) as zendesk_ticket_id
    ;;
  }

  dimension: pkey {
    type: string
    sql: ${TABLE}.pkey ;;
    hidden: yes
    primary_key: yes
  }

  dimension: jira_id {
    type: number
    sql: ${TABLE}.jira_id ;;
    hidden: yes
  }

  dimension: zendesk_ticket_id {
    type: number
    sql: ${TABLE}.zendesk_ticket_id ;;
    hidden: yes
  }
}
