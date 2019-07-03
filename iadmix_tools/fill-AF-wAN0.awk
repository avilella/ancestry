# Print header
/^#/{ print }

# Calculate AF(s)
/^[^#]/{
  # Get AC(s)
  match($0, /[\t ;]AC=[^\t ;]*/)
  num_acs = split(substr($0, RSTART+4, RLENGTH-4), acs, ",")

  # Get AN
  match($0, /[\t ;]AN=[^\t ;]*/)
  an = substr($0, RSTART+4, RLENGTH-4)

  # Print everything before original AF
  match($0, /[\t ;]AF=[^\t ;]*/)
  printf("%s", substr($0, 0, RSTART+3))

  # Calculate AF(s)
  for (i = 1; i <= num_acs; i++) {
    if (an == 0) {
      printf("%f",0)
    } else {
      printf("%f", acs[i]/an)
    }
    if (i < num_acs) {
      printf(",")
    }
  }
  # print("")
  # Print everything after original AF
  if (num_acs > 1) {
    print(substr($0, RSTART+RLENGTH))
    print("")
  } else {
    print("")
  }
}
