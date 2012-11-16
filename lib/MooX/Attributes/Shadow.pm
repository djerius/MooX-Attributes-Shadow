# --8<--8<--8<--8<--
#
# Copyright (C) 2012 Smithsonian Astrophysical Observatory
#
# This file is part of MooX-Attributes-Shadow
#
# MooX-Attributes-Shadow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# -->8-->8-->8-->8--

package MooX::Attributes::Shadow;

our $VERSION = '0.01';

use Carp;
use Params::Check qw[ check last_error ];

use Exporter 'import';

our %EXPORT_TAGS = ( all => [ qw( shadow_attrs xtract_attrs) ],
		   );
Exporter::export_ok_tags('all');

my %MAP;

sub shadow_attrs {

    my $from = shift;

    my $to = caller;

    my $args = check( {
		       fmt => { allow => sub { ref $_[0]  eq 'CODE' } },
		       attrs => { allow => sub { ref $_[0] eq 'ARRAY' && @{$_[0]}},
				},
		       },
		      { @_ } )
      or croak( "error parsing arguments: ", last_error, "\n" );


    unless ( exists $args->{attrs} ) {

	$args->{attrs} = [ eval { $from->_shadowable_attrs } ];

	croak( "must specify attrs or call shadowable_attrs in shadowed class" ) if $@;

    }

    my $has = "${to}::has";
    my %map;
    for my $attr ( @{ $args->{attrs} } ) {

	my $alias = $args->{fmt} ? $args->{fmt}->( $attr ) : $attr;
	my $priv = "_shadow_$attr";
	$map{$attr} = { priv => $priv, alias => $alias };

	no strict 'refs';
	$has->( $priv => ( is => 'ro',
 				    init_arg => $alias,
				    predicate => 1,
				  )
	      );

    }

    $MAP{$from}{$to} = \%map;

    return;
}

sub xtract_attrs {

    my $from = shift;
    my $obj = shift;
    my $to = ref $obj;

    my $map = $MAP{$from}{$to}
      or croak( "attributes must first by copied using ",
		__PACKAGE__, "::shadow_attrs\n" );

    my %attr;
    while( my ($attr, $names) = each %$map ) {

	my $priv = $names->{priv};
	my $has = "_has$priv";

	$attr{$attr} = $obj->$priv
	  if $obj->$has;
    }

    return %attr;

}

1;
__END__

=head1 NAME

MooX::Attributes::Shadow - shadow attributes of contained objects

=head1 SYNOPSIS

  # shadow Foo's attributes in Bar
  package Bar;

  use Moo;
  use Foo;

  use MooX::Attributes::Shadow ':all';

  # create attributes shadowing class Foo's a and b attributes, with a
  # prefix to avoid collisions.
  shadow_attrs( 'Foo',
               attrs => [ qw( a b ) ],
               fmt => sub { 'pfx_' . shift },
             );

  # later in the code, use the attributes when creating a new Foo
  # object.

  sub create_foo {
    my $self = shift;
    my $foo = Foo->new( xtract_attrs( Foo => $self ) );
  }


=head1 DESCRIPTION

Container classes (which contain other objects) at times need
to reflect the contained objects' attributes in their own attributes.

For example, if class B<Foo> has attribute I<a>, and class B<Bar>
contains and instantiates class B<Foo>, it may need to provide a means
of specifying a value for B<Foo>'s I<a> attribute.

Typically, one might do this:

  package Bar;

  use Moo;
  use Foo;

  has a => ( is => 'ro' );

  has foo   => ( is => 'ro',
                 lazy => 1,
                 default => sub { Foo->new( shift->a ) }
               );


This is tedious when more than one attribute is propagated.  If
B<Bar> has its own I<a> attribute, then one must do more work to
avoid name space collisions.

B<MooX::Attributes::Shadow> provides a means to reducing the agony.
It automatically creates attributes which shadow contained objects'
attributes and easily extracts them for subsequent use.

A contained class can use B<MooX::Attributes::Shadow::Role> to
simplify things even further, so that container classes using it need
not know the names of the attributes to shadow.

=head1 INTERFACE

=over

=item B<shadow_attrs>

   shadow_attrs( $contained_class, attrs => \@attrs, %options );

Create read-only attributes for the attributes in C<@attrs> and
associate them with C<$contained_class>.  There is no means of
specifying additional attribute options.

It takes the following options:

=over

=item fmt

This is a reference to a subroutine which should return a modified
attribute name (e.g. to prevent attribute collisions).  It is passed
the attribute name as its first parameters.

=back

=item B<xtract_attrs>

  %attrs = xtract_attrs( $contained_class, $container_obj );

After the container class is instantiated, B<xtract_attrs> is used to
extract attributes for B<$contained_class> from the container object.

=back

=head1 COPYRIGHT & LICENSE

Copyright 2012 Smithsonian Astrophysical Observatory

This software is released under the GNU General Public License.  You
may find a copy at

   http://www.fsf.org/copyleft/gpl.html


=head1 AUTHOR

Diab Jerius E<lt>djerius@cfa.harvard.eduE<gt>
