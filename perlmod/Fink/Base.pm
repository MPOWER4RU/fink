# -*- mode: Perl; tab-width: 4; -*-
#
# Fink::Base class
#
# Fink - a package manager that downloads source and installs it
# Copyright (c) 2001 Christoph Pfisterer
# Copyright (c) 2001-2016 The Fink Package Manager Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
#

package Fink::Base;

use strict;
use warnings;

require Exporter;
our $VERSION	 = 1.00;
our @ISA	 = qw(Exporter);

=head1 NAME

Fink::Base - basic parameter handling

=head1 SYNOPSIS

  package My::Fink;
  require Fink::Base;
  @ISA = qw(Fink::Base);

  my $obj = My::Fink->new_from_properties({ key1 => val1, ...});
  my $val = $obj->param($param);
  $obj->set_param($param, $val);

=head1 DESCRIPTION

Basic parameter handling for fink objects.

=head2 Constructors

=over 4

=item new

  my $obj = Fink::Base->new;
  my $obj = Fink::Base->new @args;

Create a new, empty fink object, and initialize it with the given arguments.

=cut

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = {};
	bless($self, $class);

	$self->initialize(@_);

	return $self;
}


=item new_from_properties

  my $obj = Fink::Base->new_from_properties({ key1 => val1, ...});
  my $obj = Fink::Base->new_from_properties({ key1 => val1, ...}, @parameters);

Create a new fink object setting its parameters to the given hash, and
initialize it with the given arguments.

Any key with a leading _ is ignored.

=cut

sub new_from_properties {
	my($proto, $props) = @_;
	my $class = ref($proto) || $proto;

	my $self = bless({}, $class);

	while (my($key, $value) = each %$props) {
		$self->{lc($key)} = $value unless $key =~ /^_/;
	}

	$self->initialize(@_);

	return $self;
}

=item initialize

  $obj->initialize;
  $obj->initialize(@parameters);

I<Protected method, do not call directly>.

All Fink::Base constructors will call initialize() just before returning
the object.

The default initialize() is empty.  You may override.

=cut

sub initialize { }


=back


=head2 Parameter queries

All keys are used case insensitively.

=over 4

=item param

  my $value = $obj->param($param);
  my $value = $obj->param($param, $default);

Returns the $value of the given $param. If $param is not set, $default
is returned (including 'undef' if no $default is given).

=cut

sub param {
	my $self = shift;
	my $param = lc shift;
	my $default_value = shift;

	if (exists $self->{$param}) {
		return $self->{$param};
	}
	return $default_value;
}

=item set_param

  $obj->set_param($param, $value);

Sets the $param to $value.  If $value is undef or '' the $param is deleted.

=cut

sub set_param {
	my $self = shift;
	my $param = lc shift;
	my $value = shift;

	if (not defined($value) or $value eq "") {
		delete $self->{$param};
	} else {
		$self->{$param} = $value;
	}
}


=item param_default

  my $value = $obj->param_default($param, $default_value);

Like param() but if the $param does not exist as a parameter $default_value
will be used.

=cut

### FIXME: doesn't param() already cover this feature?

sub param_default {
	my $self = shift;
	my $param = lc shift;
	my $default_value = shift || "";

	if (exists $self->{$param}) {
		return $self->{$param};
	}
	return $default_value;
}


=item param_boolean

  my $value = $obj->param_boolean($param);
  my $value = $obj->param_boolean($param, $default);

Interprets the value of $param as a boolean.  "True", "Yes", "On" and
"1" are all considered true while all other values are considered
false. Returns 1 for true, 0 for false. If $param is not set, $default
is returned (including 'undef' if no $default is given). The $default
is returned exactly as passed, not converted to 1/0 boolean value, so
the return is tri-state true/false/not-set.

=cut

sub param_boolean {
	my $self = shift;
	my $param = lc shift;
	my $default_value = shift;
	my $param_value;

	if (exists $self->{$param}) {
		$param_value = lc $self->{$param};
		if ($param_value =~ /^\s*(true|yes|on|1)\s*$/) {
			return 1;
		}
		return 0;
	}
	return $default_value;
}

=item has_param

  my $exists = $obj->has_param($param);

Returns a boolean indicating if the given $param is set.

=cut

sub has_param {
	my $self = shift;
	my $param = lc shift;

	if (exists $self->{$param}) {
		return 1;
	}
	return 0;
}

=item params_matching

  my @params = $obj->params_matching($regex);
  my @params = $obj->params_matching($regex, $with_case);

Returns a list of the parameters that exist for $obj that match the
given pattern $regex. Each returned value is suitable for passing to
the other param* methods. The string $regex is a treated as a perl
regular expression (which will not be further interpolated), with the
exception that it will not return parameters of which only a substring
matches. In perl terms, a leading ^ and trailing $ are applied. In
human terms, passing 'a.'  will not return parameters such as 'apple'
or 'cat'. If the optional $with_case is given and is true, matching
will be done with case-sensitivity. If $with_case is false or not
given, the matching will be case-insensitive (i.e., a /i modifier is
applied). In either case, the values returned are in their actual
case. The values are not returned in any particular order.

=cut

sub params_matching {
	my $self = shift;
	my $regex = shift;
	$regex = '' unless defined $regex;
	my $with_case = shift;
	$with_case = '' unless defined $with_case;

	$regex = "^$regex\$";
	if ($with_case) {
		$regex = qr/$regex/;
	} else {
		$regex = qr/$regex/i;
	}

	return grep { $_ =~ $regex } keys %$self;
}

=back

=cut


1;
# vim: ts=4 sw=4 noet
