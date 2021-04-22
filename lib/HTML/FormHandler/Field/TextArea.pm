package HTML::FormHandler::Field::TextArea;
# ABSTRACT: textarea input
our $VERSION = '100.000001';
use Moose;
extends 'HTML::FormHandler::Field::Text';

has '+widget' => ( default => 'Textarea' );
has 'cols'    => ( isa     => 'Int', is => 'rw' );
has 'rows'    => ( isa     => 'Int', is => 'rw' );
sub html_element { 'textarea' }

=head1 Summary

For HTML textarea. Uses 'textarea' widget. Set cols/row/minlength/maxlength.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
