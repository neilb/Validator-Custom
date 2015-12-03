package Validator::Custom;
use Object::Simple -base;
use 5.008001;
our $VERSION = '1.00';

use Carp 'croak';
use Validator::Custom::Validation;
use Validator::Custom::FilterFunction;
use Validator::Custom::CheckFunction;

# Version 0 modules(Not used now)
use Validator::Custom::Constraints;
use Validator::Custom::Constraint;
use Validator::Custom::Result;
use Validator::Custom::Rule;

sub validation { Validator::Custom::Validation->new }

sub new {
  my $self = shift->SUPER::new(@_);
  
  # Add checks
  $self->add_check(
    ascii             => \&Validator::Custom::CheckFunction::ascii,
    decimal           => \&Validator::Custom::CheckFunction::decimal,
    int               => \&Validator::Custom::CheckFunction::int,
    in                => \&Validator::Custom::CheckFunction::in,
    uint              => \&Validator::Custom::CheckFunction::uint,
    regex             => \&Validator::Custom::CheckFunction::regex,
  );
  
  # Add filters
  $self->add_filter(
    remove_blank      => \&Validator::Custom::FilterFunction::remove_blank,
    trim              => \&Validator::Custom::FilterFunction::trim,
    trim_collapse     => \&Validator::Custom::FilterFunction::trim_collapse,
    trim_lead         => \&Validator::Custom::FilterFunction::trim_lead,
    trim_trail        => \&Validator::Custom::FilterFunction::trim_trail,
    trim_uni          => \&Validator::Custom::FilterFunction::trim_uni,
    trim_uni_collapse => \&Validator::Custom::FilterFunction::trim_uni_collapse,
    trim_uni_lead     => \&Validator::Custom::FilterFunction::trim_uni_lead,
    trim_uni_trail    => \&Validator::Custom::FilterFunction::trim_uni_trail
  );
  
  # Version 0 constraints
  $self->register_constraint(
    any               => sub { 1 },
    ascii             => \&Validator::Custom::Constraint::ascii,
    between           => \&Validator::Custom::Constraint::between,
    blank             => \&Validator::Custom::Constraint::blank,
    date_to_timepiece => \&Validator::Custom::Constraint::date_to_timepiece,
    datetime_to_timepiece => \&Validator::Custom::Constraint::datetime_to_timepiece,
    decimal           => \&Validator::Custom::Constraint::decimal,
    defined           => sub { defined $_[0] },
    duplication       => \&Validator::Custom::Constraint::duplication,
    equal_to          => \&Validator::Custom::Constraint::equal_to,
    greater_than      => \&Validator::Custom::Constraint::greater_than,
    http_url          => \&Validator::Custom::Constraint::http_url,
    int               => \&Validator::Custom::Constraint::int,
    in_array          => \&Validator::Custom::Constraint::in_array,
    length            => \&Validator::Custom::Constraint::length,
    less_than         => \&Validator::Custom::Constraint::less_than,
    merge             => \&Validator::Custom::Constraint::merge,
    not_defined       => \&Validator::Custom::Constraint::not_defined,
    not_space         => \&Validator::Custom::Constraint::not_space,
    not_blank         => \&Validator::Custom::Constraint::not_blank,
    uint              => \&Validator::Custom::Constraint::uint,
    regex             => \&Validator::Custom::Constraint::regex,
    selected_at_least => \&Validator::Custom::Constraint::selected_at_least,
    shift             => \&Validator::Custom::Constraint::shift_array,
    space             => \&Validator::Custom::Constraint::space,
    string            => \&Validator::Custom::Constraint::string,
    to_array          => \&Validator::Custom::Constraint::to_array,
    to_array_remove_blank => \&Validator::Custom::Constraint::to_array_remove_blank,
    trim              => \&Validator::Custom::Constraint::trim,
    trim_collapse     => \&Validator::Custom::Constraint::trim_collapse,
    trim_lead         => \&Validator::Custom::Constraint::trim_lead,
    trim_trail        => \&Validator::Custom::Constraint::trim_trail,
    trim_uni          => \&Validator::Custom::Constraint::trim_uni,
    trim_uni_collapse => \&Validator::Custom::Constraint::trim_uni_collapse,
    trim_uni_lead     => \&Validator::Custom::Constraint::trim_uni_lead,
    trim_uni_trail    => \&Validator::Custom::Constraint::trim_uni_trail
  );
  
  return $self;
}

sub check_each {
  my ($self, $values, $name, $arg) = @_;
  
  if (@_ < 3) {
    croak "value must be passed";
  }
  
  my $checks = $self->{checks} || {};
  
  croak "Can't call \"$name\" check"
    unless $checks->{$name};
  
  croak "values must be array refernce"
    unless ref $values eq 'ARRAY';
  
  my $is_invalid;
  for my $value (@$values) {
    my $is_valid = $checks->{$name}->($self, $value, $arg);
    unless ($is_valid) {
      $is_invalid = 1;
      last;
    }
  }
  
  return $is_invalid ? 0 : 1;
}

sub filter_each {
  my ($self, $values, $name, $arg) = @_;
  
  if (@_ < 3) {
    croak "value must be passed";
  }
  
  my $filters = $self->{filters} || {};
  
  croak "Can't call \"$name\" filter"
    unless $filters->{$name};
  
  croak "values must be array refernce"
    unless ref $values eq 'ARRAY';
  
  my $new_values = [];
  for my $value (@$values) {
    my $new_value = $filters->{$name}->($self, $value, $arg);
    push @$new_values, $new_value;
  }
  
  return $new_values;
}

sub check {
  my ($self, $value, $name, $arg) = @_;

  if (@_ < 3) {
    croak "value must be passed";
  }
  
  my $checks = $self->{checks} || {};
  
  croak "Can't call \"$name\" check"
    unless $checks->{$name};
  
  return $checks->{$name}->($self, $value, $arg);
}

sub filter {
  my ($self, $value, $name, $arg) = @_;
  
  if (@_ < 3) {
    croak "value must be passed";
  }
  
  my $filters = $self->{filters} || {};
  
  croak "Can't call \"$name\" filter"
    unless $filters->{$name};
  
  return $filters->{$name}->($self, $value, $arg);
}

sub add_check {
  my $self = shift;
  
  # Merge
  my $checks = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->{checks} = ({%{$self->{checks} || {}}, %$checks});
  
  return $self;
}

sub add_filter {
  my $self = shift;
  
  # Merge
  my $filters = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->{filters} = ({%{$self->{filters} || {}}, %$filters});
  
  return $self;
}

# Version 0 method(Not used now)
our %VALID_OPTIONS = map {$_ => 1} qw/message default copy require optional/;
sub _parse_constraint {
  my ($self, $c) = @_;

  # Constraint information
  my $cinfo = {};

  # Arrange constraint information
  my $constraint = $c->{constraint};
  $cinfo->{message} = $c->{message};
  $cinfo->{original_constraint} = $c->{constraint};
  
  # Code reference
  if (ref $constraint eq 'CODE') {
    $cinfo->{funcs} = [$constraint];
  }
  # Simple constraint name
  else {
    my $constraints;
    if (ref $constraint eq 'ARRAY') {
      $constraints = $constraint;
    }
    else {
      if ($constraint =~ /\|\|/) {
        $constraints = [split(/\|\|/, $constraint)];
      }
      else {
        $constraints = [$constraint];
      }
    }
    
    # Constraint functions
    my @cfuncs;
    my @cargs;
    for my $cname (@$constraints) {
      # Arrange constraint
      if (ref $cname eq 'HASH') {
        my $first_key = (keys %$cname)[0];
        push @cargs, $cname->{$first_key};
        $cname = $first_key;
      }

      # Target is array elements
      $cinfo->{each} = 1 if $cname =~ s/^@//;
      croak qq{"\@" must be one at the top of constrinat name}
        if index($cname, '@') > -1;
      
      
      # Trim space
      $cname =~ s/^\s+//;
      $cname =~ s/\s+$//;
      
      # Negative
      my $negative = $cname =~ s/^!// ? 1 : 0;
      croak qq{"!" must be one at the top of constraint name}
        if index($cname, '!') > -1;
      
      # Trim space
      $cname =~ s/^\s+//;
      $cname =~ s/\s+$//;
      
      # Constraint function
      croak "Constraint name '$cname' must be [A-Za-z0-9_]"
        if $cname =~ /\W/;
      my $cfunc = $self->constraints->{$cname} || '';
      croak qq{"$cname" is not registered}
        unless ref $cfunc eq 'CODE';
      
      # Negativate
      my $f = $negative ? sub {
        my $ret = $cfunc->(@_);
        if (ref $ret eq 'ARRAY') {
          $ret->[0] = ! $ret->[0];
          return $ret;
        }
        else { return !$ret }
      } : $cfunc;
      
      # Add
      push @cfuncs, $f;
    }
    $cinfo->{funcs} = \@cfuncs;
    $cinfo->{args} = \@cargs;
  }
  
  return $cinfo;
}

# DEPRECATED!
has shared_rule => sub { [] };
# DEPRECATED!
__PACKAGE__->dual_attr('constraints',
  default => sub { {} }, inherit => 'hash_copy');

# Version method(Not used now)
sub create_rule { Validator::Custom::Rule->new(validator => shift) }

# Version 0 method(Not used now)
sub register_constraint {
  my $self = shift;
  
  # Merge
  my $constraints = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  $self->constraints({%{$self->constraints}, %$constraints});
  
  return $self;
}

# Version 0 method(Not used now)
sub _parse_random_string_rule {
  my $self = shift;
  
  # Rule
  my $rule = ref $_[0] eq 'HASH' ? $_[0] : {@_};
  
  # Result
  my $result = {};
  
  # Parse string rule
  for my $name (keys %$rule) {
    # Pettern
    my $pattern = $rule->{$name};
    $pattern = '' unless $pattern;
    
    # State
    my $state = 'character';

    # Count
    my $count = '';
    
    # Chacacter sets
    my $csets = [];
    my $cset = [];
    
    # Parse pattern
    my $c;
    while (defined ($c = substr($pattern, 0, 1, '')) && length $c) {
      # Character class
      if ($state eq 'character_class') {
        if ($c eq ']') {
          $state = 'character';
          push @$csets, $cset;
          $cset = [];
          $state = 'character';
        }
        else { push @$cset, $c }
      }
      
      # Count
      elsif ($state eq 'count') {
        if ($c eq '}') {
          $count = 1 if $count < 1;
          for (my $i = 0; $i < $count - 1; $i++) {
              push @$csets, [@{$csets->[-1] || ['']}];
          }
          $count = '';
          $state = 'character';
        }
        else { $count .= $c }
      }
      
      # Character
      else {
        if ($c eq '[') { $state = 'character_class' }
        elsif ($c eq '{') { $state = 'count' }
        else { push @$csets, [$c] }
      }
    }
    
    # Add Charcter sets
    $result->{$name} = $csets;
  }
  
  return $result;
}

# Version 0 method(Not used now)
sub validate {
  my ($self, $input, $rule) = @_;
  
  # Class
  my $class = ref $self;
  
  # Validation rule
  $rule ||= $self->rule;
  
  # Data filter
  my $filter = $self->data_filter;
  $input = $filter->($input) if $filter;
  
  # Check data
  croak "First argument must be hash ref"
    unless ref $input eq 'HASH';
  
  # Check rule
  unless (ref $rule eq 'Validator::Custom::Rule') {
    croak "Invalid rule structure" unless ref $rule eq 'ARRAY';
  }
  
  # Result
  my $result = Validator::Custom::Result->new;
  $result->{_error_infos} = {};
  
  # Save raw data
  $result->raw_data($input);
  
  # Error is stock?
  my $error_stock = $self->error_stock;
  
  # Valid keys
  my $valid_keys = {};
  
  # Error position
  my $pos = 0;
  
  # Found missing parameters
  my $found_missing_params = {};
  
  # Shared rule
  my $shared_rule = $self->shared_rule;
  warn "Validator::Custom::shared_rule is DEPRECATED!"
    if @$shared_rule;
  
  if (ref $rule eq 'Validator::Custom::Rule') {
    $self->rule_obj($rule);
  }
  else {
    my $rule_obj = $self->create_rule;
    $rule_obj->parse($rule, $shared_rule);
    $self->rule_obj($rule_obj);
  }
  my $rule_obj = $self->rule_obj;

  if ($rule_obj->{version} && $rule_obj->{version} == 1) {
    croak "Can't call validate method(Validator::Custom). Use \$rule->validate(\$input) instead";
  }
  
  # Process each key
  OUTER_LOOP:
  for (my $i = 0; $i < @{$rule_obj->rule}; $i++) {
    
    my $r = $rule_obj->rule->[$i];
    
    # Increment position
    $pos++;
    
    # Key, options, and constraints
    my $key = $r->{key};
    my $opts = $r->{option};
    my $cinfos = $r->{constraints} || [];
    
    # Check constraints
    croak "Invalid rule structure"
      unless ref $cinfos eq 'ARRAY';

    # Arrange key
    my $result_key = $key;
    if (ref $key eq 'HASH') {
      my $first_key = (keys %$key)[0];
      $result_key = $first_key;
      $key         = $key->{$first_key};
    }
    elsif (defined $r->{name}) {
      $result_key = $r->{name};
    }
    
    # Real keys
    my $keys;
    
    if (ref $key eq 'ARRAY') { $keys = $key }
    elsif (ref $key eq 'Regexp') {
      $keys = [];
      for my $k (keys %$input) {
         push @$keys, $k if $k =~ /$key/;
      }
    }
    else { $keys = [$key] }
    
    # Check option
    if (exists $opts->{optional}) {
      if ($opts->{optional}) {
        $opts->{require} = 0;
      }
      delete $opts->{optional};
    }
    for my $oname (keys %$opts) {
      croak qq{Option "$oname" of "$result_key" is invalid name}
        unless $VALID_OPTIONS{$oname};
    }
    
    # Default
    if (exists $opts->{default}) {
      $r->{default} = $opts->{default};
    }
    
    # Is data copy?
    my $copy = 1;
    $copy = $opts->{copy} if exists $opts->{copy};
    
    # Check missing parameters
    my $require = exists $opts->{require} ? $opts->{require} : 1;
    my $found_missing_param;
    my $missing_params = $result->missing_params;
    for my $key (@$keys) {
      unless (exists $input->{$key}) {
        if ($require && !exists $r->{default}) {
          push @$missing_params, $key
            unless $found_missing_params->{$key};
          $found_missing_params->{$key}++;
        }
        $found_missing_param = 1;
      }
    }
    if ($found_missing_param) {
      $result->data->{$result_key} = ref $r->{default} eq 'CODE'
          ? $r->{default}->($self) : $r->{default}
        if exists $r->{default} && $copy;
      next if $r->{default} || !$require;
    }
    
    # Already valid
    next if $valid_keys->{$result_key};
    
    # Validation
    my $value = @$keys > 1
      ? [map { $input->{$_} } @$keys]
      : $input->{$keys->[0]};
    
    for my $cinfo (@$cinfos) {
      
      # Constraint information
      my $args = $cinfo->{args};
      my $message = $cinfo->{message};
                                      
      # Constraint function
      my $cfuncs = $cinfo->{funcs};
      
      # Is valid?
      my $is_valid;
      
      # Data is array
      if($cinfo->{each}) {
          
        # To array
        $value = [$value] unless ref $value eq 'ARRAY';
        
        # Validation loop
        for (my $k = 0; $k < @$value; $k++) {
          my $input = $value->[$k];
          
          # Validation
          for (my $j = 0; $j < @$cfuncs; $j++) {
            my $cfunc = $cfuncs->[$j];
            my $arg = $args->[$j];
            
            # Validate
            my $cresult;
            {
              local $_ = Validator::Custom::Constraints->new(
                constraints => $self->constraints
              );
              $cresult= $cfunc->($input, $arg, $self);
            }
            
            # Constrint result
            my $v;
            if (ref $cresult eq 'ARRAY') {
              ($is_valid, $v) = @$cresult;
              $value->[$k] = $v;
            }
            elsif (ref $cresult eq 'HASH') {
              $is_valid = $cresult->{result};
              $message = $cresult->{message} unless $is_valid;
              $value->[$k] = $cresult->{output} if exists $cresult->{output};
            }
            else { $is_valid = $cresult }
            
            last if $is_valid;
          }
          
          # Validation error
          last unless $is_valid;
        }
      }
      
      # Data is scalar
      else {
        # Validation
        for (my $k = 0; $k < @$cfuncs; $k++) {
          my $cfunc = $cfuncs->[$k];
          my $arg = $args->[$k];
        
          my $cresult;
          {
            local $_ = Validator::Custom::Constraints->new(
              constraints => $self->constraints
            );
            $cresult = $cfunc->($value, $arg, $self);
          }
          
          if (ref $cresult eq 'ARRAY') {
            my $v;
            ($is_valid, $v) = @$cresult;
            $value = $v if $is_valid;
          }
          elsif (ref $cresult eq 'HASH') {
            $is_valid = $cresult->{result};
            $message = $cresult->{message} unless $is_valid;
            $value = $cresult->{output} if exists $cresult->{output} && $is_valid;
          }
          else { $is_valid = $cresult }
          
          last if $is_valid;
        }
      }
      
      # Add error if it is invalid
      unless ($is_valid) {
        if (exists $r->{default}) {
          # Set default value
          $result->data->{$result_key} = ref $r->{default} eq 'CODE'
                                       ? $r->{default}->($self)
                                       : $r->{default}
            if exists $r->{default} && $copy;
          $valid_keys->{$result_key} = 1
        }
        else {
          # Resist error info
          $message = $opts->{message} unless defined $message;
          $result->{_error_infos}->{$result_key} = {
            message      => $message,
            position     => $pos,
            reason       => $cinfo->{original_constraint},
            original_key => $key
          } unless exists $result->{_error_infos}->{$result_key};
          
          # No Error stock
          unless ($error_stock) {
            # Check rest constraint
            my $found;
            for (my $k = $i + 1; $k < @{$rule_obj->rule}; $k++) {
              my $r_next = $rule_obj->rule->[$k];
              my $key_next = $r_next->{key};
              $key_next = (keys %$key)[0] if ref $key eq 'HASH';
              $found = 1 if $key_next eq $result_key;
            }
            last OUTER_LOOP unless $found;
          }
        }
        next OUTER_LOOP;
      }
    }
    
    # Result data
    $result->data->{$result_key} = $value if $copy;
    
    # Key is valid
    $valid_keys->{$result_key} = 1;
    
    # Remove invalid key
    delete $result->{_error_infos}->{$key};
  }
  
  return $result;
}

# Version 0 attributes(Not used now)
has 'data_filter';
has 'rule';
has 'rule_obj';
has error_stock => 1;

# Version 0 method(Not used now)
sub js_fill_form_button {
  my ($self, $rule) = @_;
  
  my $r = $self->_parse_random_string_rule($rule);
  
  require JSON;
  my $r_json = JSON->new->encode($r);
  
  my $javascript = << "EOS";
(function () {

  var rule = $r_json;

  var create_random_value = function (rule, name) {
    var patterns = rule[name];
    if (patterns === undefined) {
      return "";
    }
    
    var value = "";
    for (var i = 0; i < patterns.length; i++) {
      var pattern = patterns[i];
      var num = Math.floor(Math.random() * pattern.length);
      value = value + pattern[num];
    }
    
    return value;
  };
  
  var addEvent = (function(){
    if(document.addEventListener) {
      return function(node,type,handler){
        node.addEventListener(type,handler,false);
      };
    } else if (document.attachEvent) {
      return function(node,type,handler){
        node.attachEvent('on' + type, function(evt){
          handler.call(node, evt);
        });
      };
    }
  })();
  
  var button = document.createElement("input");
  button.setAttribute("type","button");
  button.value = "Fill Form";
  document.body.insertBefore(button, document.body.firstChild)

  addEvent(
    button,
    "click",
    function () {
      
      var input_elems = document.getElementsByTagName('input');
      var radio_names = {};
      var checkbox_names = {};
      for (var i = 0; i < input_elems.length; i++) {
        var e = input_elems[i];

        var name = e.getAttribute("name");
        var type = e.getAttribute("type");
        if (type === "text" || type === "hidden" || type === "password") {
          var value = create_random_value(rule, name);
          e.value = value;
        }
        else if (type === "checkbox") {
          e.checked = Math.floor(Math.random() * 2) ? true : false;
        }
        else if (type === "radio") {
          radio_names[name] = 1;
        }
      }
      
      for (name in radio_names) {
        var elems = document.getElementsByName(name);
        var num = Math.floor(Math.random() * elems.length);
        elems[num].checked = true;
      }
      
      var textarea_elems = document.getElementsByTagName("textarea");
      for (var i = 0; i < textarea_elems.length; i++) {
        var e = textarea_elems[i];
        
        var name = e.getAttribute("name");
        var value = create_random_value(rule, name);
        
        var text = document.createTextNode(value);
        
        if (e.firstChild) {
          e.removeChild(e.firstChild);
        }
        
        e.appendChild(text);
      }
      
      var select_elems = document.getElementsByTagName("select");
      for (var i = 0; i < select_elems.length; i++) {
        var e = select_elems[i];
        var options = e.options;
        if (e.multiple) {
          for (var k = 0; k < options.length; k++) {
            options[k].selected = Math.floor(Math.random() * 2) ? true : false;
          }
        }
        else {
          var num = Math.floor(Math.random() * options.length);
          e.selectedIndex = num;
        }
      }
    }
  );
})();
EOS

  return $javascript;
}

1;

=head1 NAME

Validator::Custom - HTML form Validation, simple and good flexibility

=head1 SYNOPSYS

  use Validator::Custom;
  my $vc = Validator::Custom->new;
  
  # Input data
  my $id = 1;
  my $name = 'Ken Suzuki';
  my $age = ' 19 ';
  my $favorite = ['apple', 'orange'];
  
  # Create validation object
  my $validation = $vc->validation;
  
  # Check id
  if (!(length $id && $vc->check($id, 'int'))) {
    # Set failed message
    $validation->add_failed(id => 'id must be integer');
  }
  
  # Check name
  if (!(length $name)) {
    $validation->add_failed(name => 'name must have length');
  }
  elsif (!(length $name < 30)) {
    $validation->add_failed(name => 'name is too long');
  }
  
  # Filter age
  $age = $vc->filter($age, 'trim');

  # Check age
  if (!(length $id && $vc->check($age, 'int'))) {
    # Set default value if validation fail
    $age = 20;
  
  # Filter each value of favorite
  $favorite = $vc->filter_each($favorite, 'trim');
  
  # Check each value of favorite
  if (@$favorite == 0) {
    $validation->add_failed(favorite => 'favorite must be selected more than one');
  }
  elsif (!($vc->check_each($favorite, 'in',  ['apple', 'ornge', 'peach']))) {
    $validation->add_failed(favorite => 'favorite is invalid');
  }
  
  # Check if validation result is valid
  if ($validation->is_valid) {
    # ...
  }
  else {
    
    # Check what parameter fail
    unless ($validation->is_valid('name')) {
      # ...
    }
    
    # Get failed parameter names
    my $failed = $validation->failed;
    
    # Get failed messages
    my $messages = $validation->messages;
    
    # Get failed messages as hash
    my $messages_h = $validation->messages_to_hash;
  }
  
=head1 DESCRIPTION

L<Validator::Custom> is validator class for validate HTML form.
L<Validator::Custom> is simple and good flexibility.

The features are the following ones.

=over 4

=item *

Sevral check functions are available by default, C<ascii>,
C<int>, C<decimal>, C<uint> C<in>.

=item *

Several filter functions are available by default, such as C<trim>.

=item *

You can add your check and filter function.

=item *

You can add failed message keeping the order of validation.

=back

=head1 GUIDE

=head2 1. Basic

B<1. Create a new Validator::Custom object>

  use Validator::Custom;
  my $vc = Validator::Custom->new;

B<2. Prepare input data for validation>

  my $id = 1;
  my $name = 'Ken Suzuki';
  my $age = ' 19 ';
  my $favorite = ['apple', 'orange'];

B<3. Create validation object>

  my $validation = $vc->validation;

B<4. Validate input data>

  # Check id and set failed message
  if (!(length $id && $vc->check($id, 'int'))) {
    $validation->add_failed(id => 'id must be integer');
  }
  
  # Check name and set failed message
  if (!(length $name)) {
    $validation->add_failed(name => 'name must have length');
  }
  elsif (!(length $name < 30)) {
    $validation->add_failed(name => 'name is too long');
  }
  
  # Filter and check age, and set default value
  $age = $vc->filter($age, 'trim');
  if (!(length $id && $vc->check($age, 'int'))) {
    $age = 20;
  
  # Filter and check each favorite value
  $favorite = $vc->filter_each($favorite, 'trim');
  if (@$favorite == 0) {
    $validation->add_failed(favorite => 'favorite must be selected more than one');
  }
  elsif (!($vc->check_each($favorite, 'in',  ['apple', 'ornge', 'peach']))) {
    $validation->add_failed(favorite => 'favorite is invalid');
  }

You can use many check and filter functions,
such as C<int>, C<trim>.
See L<Validator::Custom/"CHECKS"> and L<Validator::Custom/"FILTERS">.

If input data is invalid, you can add message by C<add_failed> method.

B<5. Manipulate the validation result>
  
  # Get result
  if ($validation->is_valid) {
    # ...
  }
  else {
    
    # Know what is failed
    unless ($validation->is_valid('name')) {
      # ...
    }
    
    # Get failed list
    my $failed = $validation->failed;
    
    # Get a message
    my $title_message = $validation->message('title');
    
    # Get messages
    my $messages = $validation->messages;
    
    # Get messages as hash
    my $messages_h = $validation->messages_to_hash;
  }

If there are no failed message, C<is_valid> method return true.
You can get a message and messages by C<message>, C<messages>, C<messages_to_hash>.

See also L<Validator::Custom::Validation>.

=head2 2. Check and filter functions

=head3 Add check function

L<Validator::Custom> has various check functions.
You can see check functions added by default
L<Validator::Custom/"CHECKS">.

and you can add your check function if you need.

  $vc->add_check(
    telephone => sub {
      my ($vc, $value, $arg) = @_;
      
      my $is_valid;
      if ($value =~ /^[\d-]+$/) {
        $is_valid = 1;
      }
      return $is_valid;
    }
  );

Check function for telephone number is added.

Check function receive a value as first argument,
argument as second argument.

You must return the result of validation, true or false value.

=head3 Add filter function

Filter function is added by C<add_filter> method.

  $vc->add_filter(
    to_upper_case => sub {
      my ($vc, $value, $arg) = @_;
      
      my $new_$value = uc $value;
                  
      return $new_value;
    }
  );

Check function receive a value as first argument,
argument as second argument.

You must return the result of filtering.

=head1 CHECKS

=head2 ascii
  
  my $is_valid = $vc->check($value, 'ascii');
  
Ascii graphic characters(hex 21-7e).

Valid example:

  "Ken"

Invalid example:
  
  "aa aa"
  "\taaa"

=head2 decimal
  
  my $value = {num1 => '123', num2 => '1.45'};
  Rule: $vc->check($value, 'decimal', 3)
        $vc->check($value, 'decimal', [1, 2])

Decimal. You can specify maximum digits number at before
and after '.'.

If you set undef value or don't set any value, that means there is no maximum limit.
  
  my $value = {num1 => '1233555.89345', num2 => '1121111.45', num3 => '12.555555555'};
  Rule: $vc->->check($value, 'decimal')
        $vc->check($value, 'decimal', [undef, 2])
        $vc->check($value, 'decimal', [2, undef])

=head2 int

  my $value = 19;
  $vc->check($value, 'int');

Integer.

=head2 in
  
  my $value = 'sushi';
  my $is_valid = $vc->check($value, 'in', [qw/sushi bread apple/]);

Check if the values is in array.

=head2 uint

  my $value = 19
  $vc->check($value, 'uint');

Unsigned integer(contain zero).
  
=head1 FILTERS

You can use the following filter by default.

=head2 trim

  my $value = '  Ken  ';
  $vc->filter($value, 'trim')
  Output:{name => 'Ken'}

Trim leading and trailing white space.
Not that trim only C<[ \t\n\r\f]>
which don't contain unicode space character.

=head2 trim_collapse

  my $value = '  Ken   Takagi  ';
  $vc->filter($value, 'trim_collapse') # 
  Output:{name => 'Ken Takagi'}

Trim leading and trailing white space,
and collapse all whitespace characters into a single space.
Not that trim only C<[ \t\n\r\f]>
which don't contain unicode space character.

=head2 trim_lead

  my $value = '  Ken  ';
  $vc->filter($value, 'trim_lead')
  Output:{name => 'Ken  '}

Trim leading white space.
Not that trim only C<[ \t\n\r\f]>
which don't contain unicode space character.

=head2 trim_trail

  my $value = '  Ken  ';
  $vc->filter($value, 'trim_trail'); # '  Ken'

Trim trailing white space.
Not that trim only C<[ \t\n\r\f]>
which don't contain unicode space character.

=head2 trim_uni

  my $value = '  Ken  ';
  $vc->filter($value, 'trim_uni')
  Output:{name => 'Ken'}

Trim leading and trailing white space, which contain unicode space character.

=head2 trim_uni_collapse

  # Convert "  Ken   Takagi  " to "Ken Takagi"
  my $new_value = $vc->filter($value, 'trim_uni_collapse');
  
Trim leading and trailing white space, which contain unicode space character.

=head2 trim_uni_lead

  my $value = '  Ken  ';
  my $new_value = $vc->filter($value, 'trim_uni_lead'); #'Ken  '

Trim leading white space, which contain unicode space character.

=head2 trim_uni_trail
  
  my $value = '  Ken  ';
  $vc->filter($value, 'trim_uni_trail'); # '  Ken'

Trim trailing white space, which contain unicode space character.

=head1 METHODS

L<Validator::Custom> inherits all methods from L<Object::Simple>
and implements the following new ones.

=head2 new

  my $vc = Validator::Custom->new;

Create a new L<Validator::Custom> object.

=head2 add_check

  $vc->add_check(%check);
  $vc->add_check(\%check);

Add check function.
It receives four arguments,
Validator::Custom::Rule object, arguments of check function,
current key name, and parameters
  
  $vc->add_check(
    int => sub {
      my ($vc, $value, $args) = @_;
      
      my $is_valid = $value =~ /^\-?[\d]+$/;
      
      return $is_valid;
    }
  );

=head2 add_filter

Add filter function. 
It receives four arguments,
Validator::Custom::Rule object, arguments of check function,
current key name, and parameters,

  $vc->add_filter(
    trim => sub {
      my ($vc, $value, $args) = @_;
      
      $value =~ s/^\s+//;
      $value =~ s/\s+$//;
      
      return $value;
    }
  );

=head2 check

  my $is_valid = $vc->check($value, 'int');
  my $is_valid = $vc->check($value, 'int', $arg);

Run check.

=head2 check_each

  my $is_valid = $vc->check_each($values, 'int');
  my $is_valid = $vc->check_each($values, 'int', $arg);

Run check all elements of array refernce.
If more than one element is invalid, check_each reterun false.

=head2 filter

  my $new_value = $vc->filter($value, 'trim');
  my $new_value = $vc->filter($value, 'trim', $arg);

Run filter.

=head2 filter_each

  my $new_values = $vc->filter_each($values, 'trim');
  my $new_values = $vc->filter_each($values, 'trim', $arg);

Run filter all elements of array reference.

=head1 EXAMPLES

Password checking.
  
  my $password = 'abc';
  my $password2 = 'abc';
  
  my $validation = $vc->validation;
  
  if (!length $password) {
    $validation->add_failed(password => 'password must have length');
  }
  elsif (!$vc->check($password, 'ascii')) {
    $validation->add_failed(password => 'password contains invalid characters');
  }
  elsif ($password ne $password2) {
    $validation->add_failed(password => "two passwords don't match");
  }
  
  if ($validation->is_valid) {
    # ...
  }
  else {
    # ...
  }

Check box, selected at least 1.

  my $favorite = ['apple', 'orange'];

  my $validation = $vc->validation;
  
  if (@$favorite == 0) {
    $validation->add_failed(favorite => 'favorite must be selected at least 1');
  }
  elsif (!$vc->check($favorite, 'in', ['apple', 'orange', 'melon'])) {
    $validation->add_failed(favorite => 'favorite have invalid value');
  }
  
  if ($validtion->is_valid) {
    # ...
  }
  else {
    # ...
  }

Convert date string to Time::Piece object.

  my $date = '2014/05/16';
  
  my $validation = $vc->validation;
  
  my $date_tp;
  if (!length $datetime) {
    $validation->add_failed(date => 'date must have length');
  }
  else {
    eval { $date_tp = Time::Piece->strptime($datetime_tp, '%Y/%m/%d') };
    if (!$date_tp) {
      $validation->add_failed(date => 'date value is invalid');
    }
  }

=head1 FAQ

=head2 I use Validator::Custom 0.xx yet. I want to see documentation of Version 0.xx.

See L<Validator::Custom::Document::Version0>.

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

L<http://github.com/yuki-kimoto/Validator-Custom>

=head1 COPYRIGHT & LICENCE

Copyright 2009-2015 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
