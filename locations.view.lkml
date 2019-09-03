view: locations {
  derived_table: {
    sql: SELECT
          gl.*,
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
        FROM google.locations AS gl
        JOIN servicebc.datedimension AS dd
        ON gl.date::date = dd.datekey::date
        ;;
  }
  label: "Google My Business Locations: Service BC"


# 'client' is an internally defined short-name matching an account number to a client of GDX Analytics services
# for example: 'servicebc' is a short-name for the account holder that contains the Service BC office locations
  dimension: client {
    hidden: yes
    type: string
    sql: ${TABLE}.client ;;
    label: "Client Short-Name"
    group_label: "Identifiers"
    description: "An internal short-name for the client who controls the locations imported from Google MyBusiness API."
  }

# The Google location identifier is in the format '/accounts/*/locations/*'
  dimension: location_id {
#     hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.location_id ;;
    label: "Google Location Identifier"
    group_label: "Identifiers"
    description: "Google identifier for this location."
  }

# The real world name from Google
# This may differ from raw API results according to microservice configuration file
# Configuration files are at https://github.com/bcgov/GDX-Analytics/tree/master/microservices/google-api
  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
    label: "Location Name"
    group_label: "Identifiers"
    description: "The location's real-world name."
  }

### DATE DIMENSIONS

# location results are updated nightly; the latest data available from Google MyBusiness API is from two days ago.
  dimension_group: date {
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
    sql: ${TABLE}.date ;;
    description: "The date for these location metrics, as provided by Google My Business."
    group_label:  "Date"
    # Setting the label to nothing supresses the dimension_groups name appearing before the timeframe in the field label
    # Without this, labels on these timeframes will appear as "Date Date" and "Date Week", for example.
    label: ""
  }

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

###
# ROW MEASURES
###
  measure: count {
    hidden: yes
    type: count
    drill_fields: [location_id]
    label: "Row Count"
    description: "Row counts for these dimensions and filters."
  }


###
# METRIC MEASURES
###

### COUNTS

  measure: actions_driving_directions {
    type: sum
    sql: ${TABLE}.actions_driving_directions ;;
    group_label: "Counts"
    label: "Driving Direction Requests Count"
    description: "The number of times driving directions were requested."
  }

  measure: actions_phone {
    type: sum
    sql: ${TABLE}.actions_phone ;;
    group_label: "Counts"
    label: "Phone Number Clicks Count"
    description: "The number of times the phone number was clicked."
  }

  measure: actions_website {
    type: sum
    sql: ${TABLE}.actions_website ;;
    group_label: "Counts"
    label: "Website Clicks Count"
    description: "The number of times the website was clicked."
  }

  measure: local_post_views_search {
    type: sum
    sql: ${TABLE}.local_post_views_search ;;
    group_label: "Counts"
    label: "Local Post Views Count"
    description: "The number of times the local post was viewed on Google Search."
  }

  measure: photos_count_customers {
    type: sum
    sql: ${TABLE}.photos_count_customers ;;
    group_label: "Counts"
    label: "Customer Photos Count"
    description: "The total number of (live) media items that have been uploaded by customers."
  }

  measure: photos_count_merchant {
    type: sum
    sql: ${TABLE}.photos_count_merchant ;;
    group_label: "Counts"
    label: "Owner Photos Count"
    description: "The total number of (live) media items that have been uploaded by the owner."
  }

  measure: photos_views_customers {
    type: sum
    sql: ${TABLE}.photos_views_customers ;;
    group_label: "Counts"
    label: "Customer Photo Views Count"
    description: "The number of views on media items uploaded by customers."
  }

  measure: photos_views_merchant {
    type: sum
    sql: ${TABLE}.photos_views_merchant ;;
    group_label: "Counts"
    label: "Owner Photo Views Count"
    description: "The number of views on media items uploaded by the owner."
  }

  measure: queries_direct {
    type: sum
    sql: ${TABLE}.queries_direct ;;
    group_label: "Counts"
    label: "Shown in Direct Search Count"
    description: "The number of times the location was shown when searching for the location directly."
  }

  measure: queries_indirect {
    type: sum
    sql: ${TABLE}.queries_indirect ;;
    group_label: "Counts"
    label: "Shown in Indirect Search Count"
    description: "The number of times the location was shown as a result of a categorical search (for example, restaurant)summed over the row(s) which match the selected dimensions."
  }

  measure: views_maps {
    type: sum
    sql: ${TABLE}.views_maps ;;
    group_label: "Counts"
    label: "Views on Google Maps Count"
    description: "The number of times the location was viewed on Google Maps."
  }

  measure: views_search {
    type: sum
    sql: ${TABLE}.views_search ;;
    group_label: "Counts"
    label: "Views on Google Search Count"
    description: "The number of times the location was viewed on Google Search."
  }


### AVERAGES

  measure: average_actions_driving_directions {
    type: average
    sql: ${TABLE}.actions_driving_directions ;;
    group_label: "Averages"
    label: "Driving Direction Requests Average"
    description: "The average number of times driving directions were requested."
  }

  measure: average_actions_phone {
    type: average
    sql: ${TABLE}.actions_phone ;;
    group_label: "Averages"
    label: "Phone Number Clicks Average"
    description: "The average number of times the phone number was clicked."
  }

  measure: average_actions_website {
    type: average
    sql: ${TABLE}.actions_website ;;
    group_label: "Averages"
    label: "Website Clicks Average"
    description: "The average number of times the website was clicked."
  }

  measure: average_local_post_views_search {
    type: average
    sql: ${TABLE}.local_post_views_search ;;
    group_label: "Averages"
    label: "Local Post Views Average"
    description: "The average number of times the local post was viewed on Google Search."
  }

  measure: average_photos_count_customers {
    type: average
    sql: ${TABLE}.photos_count_customers ;;
    group_label: "Averages"
    label: "Customer Photos Average"
    description: "The average number of (live) media items that have been uploaded by customers."
  }

  measure: average_photos_count_merchant {
    type: average
    sql: ${TABLE}.photos_count_merchant ;;
    group_label: "Averages"
    label: "Owner Photos Average"
    description: "The average number of (live) media items that have been uploaded by the owner."
  }

  measure: average_photos_views_customers {
    type: average
    sql: ${TABLE}.photos_views_customers ;;
    group_label: "Averages"
    label: "Customer Photo Views Average"
    description: "The average number of views on media items uploaded by customers."
  }

  measure: average_photos_views_merchant {
    type: average
    sql: ${TABLE}.photos_views_merchant ;;
    group_label: "Averages"
    label: "Owner Photo Views Average"
    description: "The average number of views on media items uploaded by the owner."
  }

  measure: average_queries_direct {
    type: average
    sql: ${TABLE}.queries_direct ;;
    group_label: "Averages"
    label: "Shown in Direct Search Average"
    description: "The average number of times the location was shown when searching for the location directly."
  }

  measure: average_queries_indirect {
    type: average
    sql: ${TABLE}.queries_indirect ;;
    group_label: "Averages"
    label: "Shown in Indirect Search Average"
    description: "The average number of times the location was shown as a result of a categorical search (for example, restaurant)."
  }

  measure: average_views_maps {
    type: average
    sql: ${TABLE}.views_maps ;;
    group_label: "Averages"
    label: "Views on Google Maps Average"
    description: "The average number of times the location was viewed on Google Maps."
  }

  measure: average_views_search {
    type: average
    sql: ${TABLE}.views_search ;;
    group_label: "Averages"
    label: "Views on Google Search Average"
    description: "The average umber of times the location was viewed on Google Search."
  }
}
