view: driving_directions {
  derived_table: {
    sql:
      SELECT
        *
      FROM
        google.gmb_directions
      WHERE
        {% condition days_to_aggregate %} days_aggregated {% endcondition %}
    ;;
  }

  label: "Google MyBusiness Driving Directions"

  dimension: utc_query_date {
    type: date
    sql: ${TABLE}.utc_query_date ;;
    label: " Query Date in UTC"
    description: "The aggregate results will be determined based on this UTC based query date."
  }

  parameter: days_to_aggregate {
    type: unquoted
    allowed_value: {
      label: "7"
      value: "7"
    }
    allowed_value: {
      label: "30"
      value: "30"
    }
    allowed_value: {
      label: "90"
      value: "90"
    }
    description: "Days to Aggregate determines if the results you derive will be at the 7 day, 30 day, or 90 day scope on the UTC Query Date. It is a required filter."
  }

  dimension: days_aggregated {
    type: number
    sql:${TABLE}.days_aggregated ;;
    label: "Days Aggregated"
    description: "Will be either 7, 30, or 90. This will always reflect what was selected by the 'Days to Aggregate' parameter."
  }

  dimension: client_shortname {
    type: string
    sql: ${TABLE}.client_shortname ;;
    label: "Client Short-Name"
    group_label: "Location"
    description: "An internal short-name for the client who controls the locations imported from Google MyBusiness API."
  }

  dimension: location_time_zone {
    type: string
    sql: ${TABLE}.location_time_zone ;;
    label: "Location Time Zone"
    group_label: "Location"
    description: "The time zone where this location is situated."
  }

  dimension: location_postal_code {
    type: string
    sql: ${TABLE}.location_postal_code ;;
    label: "Postal Code"
    group_label: "Location"
    description: "The postal code portion of the location's address."
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}.location_name ;;
    label: "Google Identifier"
    group_label: "Location"
    description: "Google identifier for this location."
  }

  dimension: location_locality {
    type: string
    sql: ${TABLE}.location_locality ;;
    label: "Locality"
    group_label: "Location"
    description: "The city, town, or community portion of the location's address."
  }

  dimension: location_label {
    type: string
    sql: ${TABLE}.location_label ;;
    label: "Business Name"
    group_label: "Location"
    description: "The location's real-world name."
  }

  dimension: region {
    type: location
    sql_latitude: ${TABLE}.region_latitude ;;
    sql_longitude: ${TABLE}.region_longitude ;;
    label: "Region Coordinates"
    group_label: "Region"
    description: "The position of the location based on it's latitude/longitude."
  }


  dimension: rank_on_query {
    type: number
    sql: ${TABLE}.rank_on_query ;;
    label: "Rank of Region"
    group_label: "Region"
    description: "The region's rank by number of requests at this Days Aggregated and UTC Query Date."
  }

  dimension: region_label {
    type: string
    sql: ${TABLE}.region_label ;;
    label: "Region"
    group_label: "Region"
    description: "The region where these results relate to."
  }

  ###
  # MEASURES
  ###

  measure: dynamic_sum {
    type: sum
    sql: CASE
          WHEN {% parameter days_to_aggregate %} = '7' THEN ${TABLE}.region_count_seven_days
          WHEN {% parameter days_to_aggregate %} = '30' THEN ${TABLE}.region_count_thirty_days
          WHEN {% parameter days_to_aggregate %} = '90' THEN ${TABLE}.region_count_ninety_days
          ELSE NULL
         END ;;
    label: "Requests sum"
    description: "The sum of requests from this region filtered on the Days Aggregated ."
  }

  measure: dynamic_average {
    type: average
    sql: CASE
          WHEN {% parameter days_to_aggregate %} = '7' THEN ${TABLE}.region_count_seven_days
          WHEN {% parameter days_to_aggregate %} = '30' THEN ${TABLE}.region_count_thirty_days
          WHEN {% parameter days_to_aggregate %} = '90' THEN ${TABLE}.region_count_ninety_days
          ELSE NULL
         END ;;
    label: "Requests average"
    description: "The average of requests from this region filtered on the Days Aggregated ."
  }

  measure: region_count_seven_days {
#     hidden: yes
  type: sum
  sql: ${TABLE}.region_count_seven_days ;;
  label: " 7 Day Count"
  description: "The count of requests from this region over 7 days since this query date."
}

measure: region_count_thirty_days {
#     hidden: yes
type: sum
sql: ${TABLE}.region_count_thirty_days ;;
label: "30 Day Count"
description: "The count of requests from this region over 30 days since this query date."
}

measure: region_count_ninety_days {
#     hidden: yes
type: sum
sql: ${TABLE}.region_count_ninety_days ;;
label: "90 Day Count"
description: "The count of requests from this region over 90 days since this query date."
}
}
