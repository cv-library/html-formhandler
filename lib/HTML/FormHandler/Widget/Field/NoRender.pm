package HTML::FormHandler::Widget::Field::NoRender;
# ABSTRACT: no rendering widget
our $VERSION = '100.000000';
use Moose::Role;

=head1 SYNOPSIS

Renders a field as the empty string.

=cut

sub render { '' }

use namespace::autoclean;
1;
