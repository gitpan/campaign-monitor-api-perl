#
# CampaignMonitor PERL API Sample code by Nicolas Ramz <nicolas.ramz@gmail.com>
# 
# every call simply returns the result of the SOAP call
# usually, $result->{Code} is set on error (missing parameter, bad api_key/client_id,... and $result->{Success} is set on success
#
use CampaignMonitor;

# change connection settings here
my $api_key = 'enter_your_api_key_here';
my $client_id = 'enter_a_valid_client_id_here';

# You should provide a valid api_key/client_id here
my $campaign = new CampaignMonitor($api_key, {debug => true});

# checks wether foo@bar.com is an active subscriber of the list with id=enter_a_valid_list_id_here
my $result1 = $campaign->get_is_subscribed("enter_a_valid_list_id_here", 'foo@bar.com');
# on success, $result1->{Success} will be set

# gets a list of subscribers list for the specified client
my $result2 = $campaign->get_lists($client_id);
# on success, $result2->{Lists} will contain the list of subscribers lists found

# add a new user 'foo@bar.com' with name 'Foo Bar' and blank custom fields to the 'enter_a_valid_list_id_here' list
my $result3 = $campaign->add_with_custom_fields("enter_a_valid_list_id_here", 'foo@bar.com', 'Foo Bar');

# add a new user 'alien.breed@t17.com' with name AlienBreed Rulez to the 'enter_a_valid_list_id_here' list and with the following custom_fields:
#
# hobbies = video games, football
# country = fr
#
my $result4 = $campaign->add_with_custom_fields("enter_a_valid_list_id_here", 'alien.breed@t17.com', 'AlienBreed Rulez', [['hobbies', 'video games'],['hobbies', 'football'],['country', 'fr']]);
# on success, $result4->{Success} will be set