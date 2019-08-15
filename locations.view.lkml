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
          dd.sbcquarter
        FROM google.locations AS gl
        JOIN servicebc.datedimension AS dd
        ON gl.date::date = dd.datekey::date
        ;;
  }
  label: "Google MyBusiness Locations for Service BC"


# 'client' is an internally defined short-name matching an account number to a client of GDX Analytics services
# for example: 'servicebc' is a short-name for the account holder that contains the Service BC office locations
  dimension: client {
    type: string
    sql: ${TABLE}.client ;;
    label: "Client Short-Name"
    group_label: "Identifiers"
    description: "An internal short-name for the client who controls the locations imported from Google MyBusiness API."
  }

# The Google location identifier is in the format '/accounts/*/locations/*'
  dimension: location_id {
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
#   dimension_group: date {
#     type: time
#     timeframes: [
#       raw,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     convert_tz: no
#     datatype: date
#     sql: ${TABLE}.date ;;
#     description: "The date for these location metrics, as provided by Google My Business."
#     group_label:  "Date"
#   }

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
  dimension: fiscalyear {
    type: number
    sql: ${TABLE}.fiscalyear ;;
    group_label: "Date"
  }
  dimension: fiscalmonth {
    type: number
    sql: ${TABLE}.fiscalmonth ;;
    group_label: "Date"
  }
  dimension: fiscalquarter {
    type: number
    sql: "Q" || ${TABLE}.fiscalquarter ;;
    group_label: "Date"
  }
  dimension: fiscal_quarter_of_year {
    type:  date_fiscal_quarter_of_year
    sql:  ${TABLE}.welcome_time ;;
    group_label:  "Date"
  }

###
# ROW MEASURES
###
  measure: count {
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
    group_label: "Sum Counts"
    label: "Driving Direction Requests (sum)"
    description: "The number of times driving directions were requested summed over the row(s) which match the selected dimensions."
  }

  measure: actions_phone {
    type: sum
    sql: ${TABLE}.actions_phone ;;
    group_label: "Sum Counts"
    label: "Phone Number Clicks (sum)"
    description: "The number of times the phone number was clicked summed over the row(s) which match the selected dimensions."
  }

  measure: actions_website {
    type: sum
    sql: ${TABLE}.actions_website ;;
    group_label: "Sum Counts"
    label: "Website Clicks (sum)"
    description: "The number of times the website was clicked summed over the row(s) which match the selected dimensions."
  }

  measure: local_post_views_search {
    type: sum
    sql: ${TABLE}.local_post_views_search ;;
    group_label: "Sum Counts"
    label: "Local Post Views (sum)"
    description: "The number of times the local post was viewed on Google Search summed over the row(s) which match the selected dimensions."
  }

  measure: photos_count_customers {
    type: sum
    sql: ${TABLE}.photos_count_customers ;;
    group_label: "Sum Counts"
    label: "Customer Photos (sum)"
    description: "The total number of media items that are currently live that have been uploaded by customers summed over the row(s) which match the selected dimensions."
  }

  measure: photos_count_merchant {
    type: sum
    sql: ${TABLE}.photos_count_merchant ;;
    group_label: "Sum Counts"
    label: "Merchant Photos (sum)"
    description: "The total number of media items that are currently live that have been uploaded by the merchant summed over the row(s) which match the selected dimensions."
  }

  measure: photos_views_customers {
    type: sum
    sql: ${TABLE}.photos_views_customers ;;
    group_label: "Sum Counts"
    label: "Customer Photo Views (sum)"
    description: "The number of views on media items uploaded by customers summed over the row(s) which match the selected dimensions."
  }

  measure: photos_views_merchant {
    type: sum
    sql: ${TABLE}.photos_views_merchant ;;
    group_label: "Sum Counts"
    label: "Merchant Photo Views (sum)"
    description: "The number of views on media items uploaded by the merchant summed over the row(s) which match the selected dimensions."
  }

  measure: queries_direct {
    type: sum
    sql: ${TABLE}.queries_direct ;;
    group_label: "Sum Counts"
    label: "Shown in Direct Search (sum)"
    description: "The number of times the resource was shown when searching for the location directly summed over the row(s) which match the selected dimensions."
  }

  measure: queries_indirect {
    type: sum
    sql: ${TABLE}.queries_indirect ;;
    group_label: "Sum Counts"
    label: "Shown in Indirect Search (sum)"
    description: "The number of times the resource was shown as a result of a categorical search (for example, restaurant)summed over the row(s) which match the selected dimensions."
  }

  measure: views_maps {
    type: sum
    sql: ${TABLE}.views_maps ;;
    group_label: "Sum Counts"
    label: "Viewed on Google Maps (sum)"
    description: "The number of times the resource was viewed on Google Maps summed over the row(s) which match the selected dimensions."
  }

  measure: views_search {
    type: sum
    sql: ${TABLE}.views_search ;;
    group_label: "Sum Counts"
    label: "Viewed on Google Search (sum)"
    description: "The number of times the resource was viewed on Google Search summed over the row(s) which match the selected dimensions."
  }


### AVERAGES

  measure: average_actions_driving_directions {
    type: average
    sql: ${TABLE}.actions_driving_directions ;;
    group_label: "Average Counts"
    label: "Driving Direction Requests (avg)"
    description: "The average number of times driving directions were requested calculated over the row(s) which match the selected dimensions."
  }

  measure: average_actions_phone {
    type: average
    sql: ${TABLE}.actions_phone ;;
    group_label: "Average Counts"
    label: "Phone Number Clicks (avg)"
    description: "The average number of times the phone number was clicked calculated over the row(s) which match the selected dimensions."
  }

  measure: average_actions_website {
    type: average
    sql: ${TABLE}.actions_website ;;
    group_label: "Average Counts"
    label: "Website Clicks (avg)"
    description: "The average number of times the website was clicked calculated over the row(s) which match the selected dimensions."
  }

  measure: average_local_post_views_search {
    type: average
    sql: ${TABLE}.local_post_views_search ;;
    group_label: "Average Counts"
    label: "Local Post Views (avg)"
    description: "The average number of times the local post was viewed on Google Search calculated over the row(s) which match the selected dimensions."
  }

  measure: average_photos_count_customers {
    type: average
    sql: ${TABLE}.photos_count_customers ;;
    group_label: "Average Counts"
    label: "Customer Photos (avg)"
    description: "The average number of media items that are currently live that have been uploaded by customers calculated over the row(s) which match the selected dimensions."
  }

  measure: average_photos_count_merchant {
    type: average
    sql: ${TABLE}.photos_count_merchant ;;
    group_label: "Average Counts"
    label: "Merchant Photos (avg)"
    description: "The average number of media items that are currently live that have been uploaded by the merchant calculated over the row(s) which match the selected dimensions."
  }

  measure: average_photos_views_customers {
    type: average
    sql: ${TABLE}.photos_views_customers ;;
    group_label: "Average Counts"
    label: "Customer Photo Views (avg)"
    description: "The average number of views on media items uploaded by customers calculated over the row(s) which match the selected dimensions."
  }

  measure: average_photos_views_merchant {
    type: average
    sql: ${TABLE}.photos_views_merchant ;;
    group_label: "Average Counts"
    label: "Merchant Photo Views (avg)"
    description: "The average number of views on media items uploaded by the merchant calculated over the row(s) which match the selected dimensions."
  }

  measure: average_queries_direct {
    type: average
    sql: ${TABLE}.queries_direct ;;
    group_label: "Average Counts"
    label: "Shown in Direct Search (avg)"
    description: "The average number of times the resource was shown when searching for the location directly calculated over the row(s) which match the selected dimensions."
  }

  measure: average_queries_indirect {
    type: average
    sql: ${TABLE}.queries_indirect ;;
    group_label: "Average Counts"
    label: "Shown in Indirect Search (avg)"
    description: "The average number of times the resource was shown as a result of a categorical search (for example, restaurant) calculated over the row(s) which match the selected dimensions."
  }

  measure: average_views_maps {
    type: average
    sql: ${TABLE}.views_maps ;;
    group_label: "Average Counts"
    label: "Viewed on Google Maps (avg)"
    description: "The average number of times the resource was viewed on Google Maps calculated over the row(s) which match the selected dimensions."
  }

  measure: average_views_search {
    type: average
    sql: ${TABLE}.views_search ;;
    group_label: "Average Counts"
    label: "Viewed on Google Search (avg)"
    description: "The average umber of times the resource was viewed on Google Search calculated over the row(s) which match the selected dimensions."
  }
}
