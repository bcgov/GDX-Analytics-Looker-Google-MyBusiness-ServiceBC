view: driving_directions {
  derived_table: {
    sql:
      SELECT
        gd.*,
        oi.site AS office_site,
        oi.officesize AS office_size,
        oi.area AS area_number,
        oi.id AS office_id,
        oi.current_area as current_area,
        dd.isweekend::BOOLEAN,
        dd.isholiday::BOOLEAN,
        dd.lastdayofpsapayperiod::date,
        dd.fiscalyear,
        dd.fiscalmonth,
        dd.fiscalquarter,
        dd.sbcquarter,
        dd.day,
        dd.weekday,
        dd.weekdayname
      FROM
        google.gmb_directions AS gd
      JOIN servicebc.datedimension AS dd
        ON gd.utc_query_date::date = dd.datekey::date
      LEFT JOIN servicebc.office_info AS oi
        ON gd.location_name = oi.google_location_id AND oi.end_date IS NULL
      WHERE
        {% condition days_to_aggregate %} gd.days_aggregated {% endcondition %}
    ;;
  }

  label: "Google MyBusiness Driving Directions"

  dimension_group: utc_query_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
#       quarter,
      year
    ]
    convert_tz: no
    datatype: date
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

  ### REGION COUNT DIMENSIONS

  dimension: region_count_seven_days {
    type: number
    sql: ${TABLE}.region_count_seven_days ;;
    label: " 7 Day Count"
    group_label: "Region Counts"
    description: "The count of requests from this region over 7 days since this query date."
  }

  dimension: region_count_thirty_days {
    type: number
    sql: ${TABLE}.region_count_thirty_days ;;
    label: "30 Day Count"
    group_label: "Region Counts"
    description: "The count of requests from this region over 30 days since this query date."
  }

  dimension: region_count_ninety_days {
    type: number
    sql: ${TABLE}.region_count_ninety_days ;;
    label: "90 Day Count"
    group_label: "Region Counts"
    description: "The count of requests from this region over 90 days since this query date."
  }

### OFFICE INFO DIMENSIONS

  # site comes from servicebc.office_info
  dimension: office_site {
    type:  string
    sql:  ${TABLE}.office_site ;;
    label: "Office Site Name"
    group_label: "Office Info"
    description: "The Service BC office site name."
  }

  dimension: office_size {
    type:  string
    sql:  ${TABLE}.office_size ;;
    label: "Office Size"
    group_label: "Office Info"
    description: "The Service BC office size."
  }

  dimension: area_number {
    type:  number
    sql:  ${TABLE}.area_number ;;
    label: "Office Area Number"
    group_label: "Office Info"
    description: "The Service BC office area number."
  }

  dimension: office_id {
    type:  number
    sql:  ${TABLE}.office_id ;;
    label: "Office ID"
    group_label: "Office Info"
    description: "The Service BC office identifier."
  }

  dimension: current_area {
    type: string
    sql:${TABLE}.current_area ;;
    drill_fields: [ office_site ]
    label: "Office Current Area"
    group_label: "Office Info"
    description: "The Service BC office current area."
  }

### DATE DIMENSIONS

## fields joined from servicebc.datedimension
  dimension: is_weekend {
    type:  yesno
    sql:  ${TABLE}.isweekend ;;
    group_label:  "Date"
  }
  dimension: is_holiday {
    type:  yesno
    sql:  ${TABLE}.isholiday ;;
    group_label:  "Date"
  }
  dimension: day_of_week {
    type:  string
    sql:  ${TABLE}.weekdayname ;;
    group_label:  "Date"
  }
  dimension: day_of_week_number {
    type: number
    sql: ${TABLE}.weekday ;;
    group_label: "Date"
  }
  dimension: sbc_quarter {
    type:  string
    sql:  ${TABLE}.sbcquarter ;;
    group_label:  "Date"
  }
  dimension: last_day_of_pay_period {
    type: date
    sql:  ${TABLE}.lastdayofpsapayperiod ;;
    group_label: "Date"
  }
  dimension: day_of_month {
    type: number
    sql: ${TABLE}.day ;;
    group_label: "Date"
  }
  dimension: fiscal_year {
    type: number
    sql: ${TABLE}.fiscalyear ;;
    group_label: "Date"
  }
  dimension: fiscal_month {
    type: number
    sql: ${TABLE}.fiscalmonth ;;
    group_label: "Date"
  }
  dimension: fiscal_quarter {
    type: number
    sql: ${TABLE}.fiscalquarter ;;
    group_label: "Date"
  }
  dimension: fiscal_quarter_of_year {
    type: string
    sql:  'Q' || ${fiscal_quarter} ;;
    group_label:  "Date"
  }
}
