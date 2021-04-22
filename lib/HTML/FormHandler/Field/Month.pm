package HTML::FormHandler::Field::Month;
# ABSTRACT: select list 1 to 12
our $VERSION = '100.000001';
use Moose;
extends 'HTML::FormHandler::Field::IntRange';

has '+range_start' => ( default => 1 );
has '+range_end'   => ( default => 12 );

=head1 DESCRIPTION

Select list for range of 1 to 12. Widget type is 'select'

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
