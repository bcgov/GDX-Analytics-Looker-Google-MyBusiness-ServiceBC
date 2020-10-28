connection: "redshift_pacific_time"
# Set the week start day to Sunday. Default is Monday
week_start_day: sunday
# Set fiscal year to begin April 1st -- https://docs.looker.com/reference/model-params/fiscal_month_offset
fiscal_month_offset: 3

label: "Google My Business"

# include all views in this project
include: "/Views/*.view"


explore: locations {
  label: "Service BC Locations"
  sql_always_where: ${client} = 'servicebc' ;;
}

explore: driving_directions {
  label: "Service BC Driving Directions"
  sql_always_where: ${client_shortname} = 'servicebc' ;;
}
