import subprocess,os
import datetime

my_env = os.environ.copy()
my_env["PATH"] = f"/Users/channing/.nix-profile/bin:{my_env['PATH']}"

# Find the secret key in the keychain
# Add it with security add-generic-password -a $LOGNAME -s octopus-sk -w 'sk_SECRET'
sk = subprocess.check_output("security find-generic-password -w -a $LOGNAME -s octopus-sk", shell=True).strip().decode("utf-8")

cmd=f"curl -s -u \"{sk}\" https://api.octopus.energy/v1/electricity-meter-points/1900005046235/meters/17K0496555/consumption/ | jq -r '.results | .[0].interval_end '"

# Run the shell command and capture its output
output = subprocess.check_output(cmd, env=my_env, shell=True)

now=datetime.datetime.now()

# Parse the output as a datetime object
date_string = output.strip().decode("utf-8")[0:10]
date = datetime.datetime.strptime(date_string, '%Y-%m-%d')
date_now_string = now.strftime("%Y-%m-%d %H:%M:%S")

# Calculate the age of the date and check if it's more than 3 days old
age = now - date
if age.days > 2:
    print(f"{date_now_string} Octopus is missing data since {date_string}")
else:
    print(f"{date_now_string} Octopus has data to {date_string}")

