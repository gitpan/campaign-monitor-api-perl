#
# CampaignMonitor PERL API by Nicolas Ramz <nicolas.ramz@gmail.com>
# 
# version 0.5 - TODO: error handling, implement missing API calls
#
# Methods implemented:
#
# Client.GetLists
# Subscriber.AddAndResubscribeWithCustomFields
# Subscriber.AddWithCustomFields
# Subscriber.Unsubscribe
# Subscribers.GetIsSubscribed 
# Subscribers.GetUnsubscribed
#
# TODO: add option to enable/disable trace debug mode
# TODO: implement missing API calls (even though it's kinda straighforward)
#
package CampaignMonitor;

# uncomment to trace soap calls
#use SOAP::Lite +trace => 'debug';
use SOAP::Lite;
use Data::Dumper;

# Campaign Monitor constructor, expects:
#
# @params: api_key, client_id
#
sub new
{
    my $class = shift;

    eval{
        unless ((scalar @_) > 0)
        {
            die('ERROR: CampaignMonitor requires client_id and api_key args !');
        }
    };

	my $self = {
        api_namespace => "http://api.createsend.com/api/", # the Campaign Monitor SOAP namespace
        api_url => "http://api.createsend.com/api/api.asmx" # the URL to the Campaign Monitor API
    };
    
    # get needed parameters
    $self->{api_key} = shift;
    $self->{options} = shift;

    bless $self, $class;
    $self->log('api_key='.$self->{api_key}.', debug='.$self->{options}->{debug});
	$self->initialize();
	return $self;
}

# returns true or false as the existence of the given email address in the supplied list 
#
# @params: list_id, email
#
# @returns: $result hash and throws (TODO) an exception if an error occurs
sub get_is_subscribed
{
    my $self = shift;
    my ($list_id, $email) = @_;

    $self->log('get_is_subscribed(list_id='.$list_id.', email='.$email.')');
    
    my $method_name = "Subscribers.GetIsSubscribed";
    my $params = [$self->soap_arg('ApiKey', $self->{api_key}), $self->soap_arg('ListID', $list_id), $self->soap_arg('Email', $email)];

    my $result = $self->soap_call($method_name, $params);

    return $result;
}

# unsubscribes the specified user from the specified list
#
# @params: list_id, email
#
# @returns: $result hash throws (TODO) an exception if an error occurs
#
# NOTE: trying to unsubscribe a user already unsubscribed will return an error
#
sub unsubscribe
{
    my $self = shift;
    my ($list_id, $email) = @_;

    $self->log('unsubscribe(list_id='.$list_id.', email='.$email);
    
    my $method_name = "Subscriber.Unsubscribe";
    my $params = [$self->soap_arg('ApiKey', $self->{api_key}), $self->soap_arg('ListID', $list_id), $self->soap_arg('Email', $email)];

    my $result = $self->soap_call($method_name, $params);

    return $result;
}

# returns the list of subscribtion lists for the current client
#
# @params: none
#
# @returns: $result hash (TODO) an exception if an error occurs
#
sub get_lists
{
    my $self = shift;
    my $client_id = shift;
    $self->log('get_lists');

    my $method_name = "Client.GetLists";
    my $params = [$self->soap_arg('ApiKey', $self->{api_key}), $self->soap_arg('ClientID', $client_id)];

    my $result = $self->soap_call($method_name, $params);

    return $result;
}

# returns true or false as the existence of the given email adress in the supplied list 
#
# @params: list_id, email, name (first+last name ?), [ [fieldName, value], [fieldName2, value2], ...]
#
# @returns: $result hash_ref (TODO) an exception if an error occurs
#
# NOTE: adding an existing user with no custom_fields will simply reset its fields
#
sub add_with_custom_fields
{
    my $self = shift;
    $self->log('add_with_custom_fields');

    my ($list_id, $email, $name, $custom_fields) = @_;

    my $method_name = "Subscriber.AddWithCustomFields";
    
    # prepare standard parameters
    my $params = [$self->soap_arg('ApiKey', $self->{api_key}), $self->soap_arg('ListID', $list_id), $self->soap_arg('Email', $email), $self->soap_arg('Name', $name)];

    # now add custom_fields if any
    if ($custom_fields)
    {
        my $fields = [];

        foreach(@{$custom_fields})
        {
            push(@{$fields}, ["SubscriberCustomField", 
                [["Key", $_->[0]], ["Value", $_->[1]]]
            ]);
        }

        push(@{$params}, $self->soap_arg("CustomFields", $fields));
    }

    return $self->soap_call($method_name, $params);
}


# Gets a list of all subscribers for a list that have unsubscribed since the specified date
#
# @params: $list_id, $date (Date Object)
#
# @returns: SOAP $result hash and throws (TODO) an exception if an error occurs
#
sub get_unsubscribed
{
    my $self = shift;
    $self->log('get_unsubscribed');

    my ($list_id, $date) = @_;

    my $method_name = "Subscribers.GetUnsubscribed";

    my $params = [ $self->soap_arg('ApiKey', $self->{api_key}), $self->soap_arg('ListID', $list_id), $self->soap_arg($date) ];

    return $self->soap_call($method_name, $params);
}

# attempts to call the specified soap method with the given parameters
#
# @params: method_name, params: array_ref (of SOAP::Data objects ref)
#
# @returns: SOAP $result hash and throws (TODO) an exception if an error occurs
#
sub soap_call
{
    my ($self, $method_name, $params) = @_;
    my $method = SOAP::Data->name($method_name)->attr({xmlns => $self->{api_namespace}});

    my $result = $self->{service}->on_action(sub { return $self->{api_namespace}.$method_name })
        ->call($method => @{$params})
        ->result;

    if ($result->{Code})
    {
        $self->log('Error Code: '.$result->{Code}.' while calling '.$method_name.' ('.$result->{Message}.')') if $self->{options}->{debug};
    }
    else
    {
        $self->log('Success calling: '.$method_name.' ('.$result->{Message}.')') if $self->{options}->{debug};
    }

    return $result;
}


# builds a SOAP Data object with specified name/value
# value can be a scalar or an array_ref
#
# @params: method_name, params: array_ref (of SOAP::Data objects ref)
#
# @returns: SOAP Data object ref
#
sub soap_arg
{
    my ($self, $name, $value) = @_;

    if (ref($value) !~ /ARRAY/)
    {
        return SOAP::Data->name($name)->value($value);
    }
    else
    {
        return $self->soapify([$name, $value]);
    }
}

# sets api_key/namespace as required for SOAP calls
#
sub initialize
{
    my $self = shift;
    $self->log("initialize()");
    $self->{service} = SOAP::Lite->uri($self->{api_namespace})->proxy($self->{api_url});
}

# 
#
sub log
{
    my ($self, $msg) = @_;

    print '['.ref($self).'] '.$msg."\n" if $self->{options}->{debug};
}

# will return a SOAP::Data object built of the specified array
#
# made by Sandeep Satavlekar (found here: http://www.soaplite.com/2004/01/building_an_arr.html)
# so Sandeep, if you read that: thanks ! :)
#
sub soapify
{
    my ($self, $args) = (@_);

    print "The argument must be an arrayref!" if (ref($args) !~ /ARRAY/ );

    my @namevaluearray = @$args;
    my $soapobject = new SOAP::Data;

    if (defined ($namevaluearray[0]) && ref($namevaluearray[0]) !~ /ARRAY/)
    {
        # name
        $soapobject->name($namevaluearray[0]);

        
        # final node reached
        if (defined $namevaluearray[1] && !ref($namevaluearray[1]))
        {
            $soapobject->value($namevaluearray[1]);
        } #looks like we have an array
        elsif (ref($namevaluearray[1]) =~ /ARRAY/)
        {
            my $soapvalue = $self->soapify($namevaluearray[1]);
            my @pass = (ref($soapvalue) =~ /ARRAY/) ? @$soapvalue : ($soapvalue);
            $soapobject->value(\SOAP::Data->value(@pass));
        }

        # finally look for any optionnal arguments
        my $attr = $namevaluearray[2];
        
        if (ref($attr) =~ /HASH/)
        {
            $soapobject->attr($attr);
        }
    }
    elsif (ref($namevaluearray[0]) =~ /ARRAY/)
    {
        my @valuesarray;
        foreach my $element (@namevaluearray)
        {
            my $reftoelement = (ref($element) =~ /ARRAY/) ? $element : [$element];
            push(@valuesarray, $self->soapify($reftoelement));
        }
        return [@valuesarray];
    }

    return $soapobject;
}

1;