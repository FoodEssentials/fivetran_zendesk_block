connection: "bigquery"

include: "*_zendesk_block.view"
include: "*_zendesk_variables.view"
include: "*.dashboard"
include: "//jira_block/bigquery/issue.view"
include: "//jira_block/bigquery/*.view"
include: "//jira_block/models/*.view"

datagroup: fivetran_datagroup {
  sql_trigger: SELECT MAX(TIMESTAMP_TRUNC(done, MINUTE)) FROM jira.fivetran_audit ;;
  max_cache_age: "24 hours"
}

persist_with: fivetran_datagroup

explore: ticket {
  join: assignee {
    sql_on: ${ticket.assignee_id} = ${assignee.id} ;;
    relationship: many_to_one
  }

  join: requester {
    sql_on: ${ticket.requester_id} = ${requester.id} ;;
    relationship: many_to_one
  }

  join: group_member {
    sql_on: ${assignee.id} = ${group_member.user_id} ;;
    relationship: many_to_one
  }

  join: group {
    sql_on: ${group_member.group_id} = ${group.id} ;;
    relationship: many_to_one
  }

  join: organization_member {
    sql_on: ${requester.id} = ${organization_member.user_id} ;;
    relationship: many_to_one
  }

  join: organization {
    sql_on: ${organization_member.organization_id} = ${organization.id} ;;
    relationship: many_to_one
  }

  join: brand {
    type: left_outer
    sql_on: ${ticket.brand_id} = ${brand.id} ;;
    relationship: many_to_one
  }

  join: ticket_comment {
    type: left_outer
    sql_on: ${ticket.id} = ${ticket_comment.ticket_id} ;;
    relationship: one_to_many
  }

  join: commenter {
    sql_on: ${ticket_comment.user_id} = ${commenter.id} ;;
    relationship: many_to_one
  }

  join: ticket_assignee_facts {
    type: left_outer
    sql_on: ${ticket.assignee_id} = ${ticket_assignee_facts.assignee_id} ;;
    relationship: many_to_one
  }

  # metric queries

  join: ticket_history_facts {
    sql_on: ${ticket.id} = ${ticket_history_facts.ticket_id} ;;
    relationship: one_to_one
  }

  join: number_of_reopens {
    sql_on: ${ticket.id} = ${number_of_reopens.ticket_id} ;;
    relationship: one_to_one
  }

  join: ticket_tags {
    sql_on: ${ticket.id} = ${ticket_tags.ticket_id} ;;
    relationship: many_to_many
  }

  # adding JIRA Information
  join: jira_zendesk_ids {
    relationship: one_to_many
    sql_on: ${ticket.id} = ${jira_zendesk_ids.zendesk_ticket_id} ;;
  }

  join: issue {
    view_label: "JIRA Issue"
    relationship: many_to_one
    sql_on: ${issue.id} = ${jira_zendesk_ids.jira_id} ;;
  }

  join: issue_extended {
    view_label: "JIRA Issue Extended"
    relationship: many_to_one
    sql_on: ${issue_extended.id} = ${jira_zendesk_ids.jira_id} ;;
  }

  join: project {
    view_label: "JIRA Project"
    type: left_outer
    relationship: many_to_one
    sql_on: ${issue.project} = ${project.id} ;;
  }

  join: point_normalization {
    view_label: "JIRA Issue"
    relationship: many_to_one
    sql_on: TIMESTAMP_TRUNC(${issue.resolved_raw}, MONTH) = ${point_normalization.month}
      AND ${project.key} = ${point_normalization.project_key} ;;
  }

  join: status {
    view_label: "JIRA Status"
    type: left_outer
    relationship: many_to_one
    sql_on: ${issue.status} = ${status.id} ;;
  }

  join: issue_sprint {
    view_label: "JIRA Sprint"
    type: left_outer
    sql_on: ${issue_sprint.issue_id} = ${issue.id} ;;
    relationship: many_to_one
  }

  join: sprint {
    view_label: "JIRA Sprint"
    from: sprint
    type: left_outer
    sql_on: ${issue_sprint.sprint_id} = ${sprint.id} ;;
    relationship: many_to_one
  }

  join: epic {
    view_label: "JIRA Epic"
    type: left_outer
    relationship: many_to_one
    sql_on: ${issue.epic_link} = ${epic.id} ;;
  }

  join: epic_status {
    view_label: "JIRA Issue"
    from: field_option
    type: left_outer
    relationship: many_to_one
    sql_on: ${issue.epic_status} = ${epic_status.id} ;;
  }

}
