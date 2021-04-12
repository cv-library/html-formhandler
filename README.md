# SYNOPSIS

See the manual at [HTML::FormHandler::Manual](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual).

    use HTML::FormHandler; # or a custom form: use MyApp::Form::User;
    my $form = HTML::FormHandler->new( .... );
    $form->process( params => $params );
    my $rendered_form = $form->render;
    if( $form->validated ) {
        # perform validated form actions
    }
    else {
        # perform non-validated actions
    }

Or, if you want to use a form 'result' (which contains only the form
values and error messages) instead:

    use MyApp::Form; # or a generic form: use HTML::FormHandler;
    my $form = MyApp::Form->new( .... );
    my $result = $form->run( params => $params );
    if( $result->validated ) {
        # perform validated form actions
    }
    else {
        # perform non-validated actions
        $result->render;
    }

An example of a custom form class:

    package MyApp::Form::User;

    use HTML::FormHandler::Moose;
    extends 'HTML::FormHandler';
    use Moose::Util::TypeConstraints;

    has '+item_class' => ( default => 'User' );

    has_field 'name' => ( type => 'Text' );
    has_field 'age' => ( type => 'PosInteger', apply => [ 'MinimumAge' ] );
    has_field 'birthdate' => ( type => 'DateTime' );
    has_field 'birthdate.month' => ( type => 'Month' );
    has_field 'birthdate.day' => ( type => 'MonthDay' );
    has_field 'birthdate.year' => ( type => 'Year' );
    has_field 'hobbies' => ( type => 'Multiple' );
    has_field 'address' => ( type => 'Text' );
    has_field 'city' => ( type => 'Text' );
    has_field 'state' => ( type => 'Select' );
    has_field 'email' => ( type => 'Email' );

    has '+dependency' => ( default => sub {
          [ ['address', 'city', 'state'], ]
       }
    );

    subtype 'MinimumAge'
       => as 'Int'
       => where { $_ > 13 }
       => message { "You are not old enough to register" };

    no HTML::FormHandler::Moose;
    1;

A dynamic form - one that does not use a custom form class - may be
created using the 'field\_list' attribute to set fields:

    my $form = HTML::FormHandler->new(
        name => 'user_form',
        item => $user,
        field_list => [
            'username' => {
                type  => 'Text',
                apply => [ { check => qr/^[0-9a-z]*\z/,
                   message => 'Contains invalid characters' } ],
            },
            'select_bar' => {
                type     => 'Select',
                options  => \@select_options,
                multiple => 1,
                size     => 4,
            },
        ],
    );

FormHandler does not provide a custom controller for Catalyst because
it isn't necessary. Interfacing to FormHandler is only a couple of
lines of code. See [HTML::FormHandler::Manual::Catalyst](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ACatalyst) for more
details, or [Catalyst::Manual::Tutorial::09\_AdvancedCRUD::09\_FormHandler](https://metacpan.org/pod/Catalyst%3A%3AManual%3A%3ATutorial%3A%3A09_AdvancedCRUD%3A%3A09_FormHandler).

# DESCRIPTION

\*\*\* Although documentation in this file provides some overview, it is mainly
intended for API documentation. See [HTML::FormHandler::Manual::Intro](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AIntro)
for an introduction, with links to other documentation.

HTML::FormHandler maintains a clean separation between form construction
and form rendering. It allows you to define your forms and fields in a
number of flexible ways. Although it provides renderers for HTML, you
can define custom renderers for any kind of presentation.

HTML::FormHandler allows you to define form fields and validators. It can
be used for both database and non-database forms, and will
automatically update or create rows in a database. It can be used
to process structured data that doesn't come from an HTML form.

One of its goals is to keep the controller/application program interface as
simple as possible, and to minimize the duplication of code. In most cases,
interfacing your controller to your form is only a few lines of code.

With FormHandler you shouldn't have to spend hours trying to figure out how to make a
simple HTML change that would take one minute by hand. Because you \_can\_ do it
by hand. Or you can automate HTML generation as much as you want, with
template widgets or pure Perl rendering classes, and stay completely in
control of what, where, and how much is done automatically. You can define
custom renderers and display your rendered forms however you want.

You can split the pieces of your forms up into logical parts and compose
complete forms from FormHandler classes, roles, fields, collections of
validations, transformations and Moose type constraints.
You can write custom methods to process forms, add any attribute you like,
and use Moose method modifiers.  FormHandler forms are Perl classes, so there's
a lot of flexibility in what you can do.

HTML::FormHandler provides rendering through roles which are applied to
form and field classes (although there's no reason you couldn't write
a renderer as an external object either).  There are currently two flavors:
all-in-one solutions like [HTML::FormHandler::Render::Simple](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3ARender%3A%3ASimple) and
[HTML::FormHandler::Render::Table](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3ARender%3A%3ATable) that contain methods for rendering
field widget classes, and the [HTML::FormHandler::Widget](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AWidget) roles, which are
more atomic roles which are automatically applied to fields and form. See
[HTML::FormHandler::Manual::Rendering](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ARendering) for more details.
(And you can easily use hand-built forms - FormHandler doesn't care.)

The typical application for FormHandler would be in a Catalyst, DBIx::Class,
Template Toolkit web application, but use is not limited to that. FormHandler
can be used in any Perl application.

More Formhandler documentation and a tutorial can be found in the manual
at [HTML::FormHandler::Manual](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual).

# ATTRIBUTES and METHODS

## Creating a form with 'new'

The new constructor takes name/value pairs:

    MyForm->new(
        item    => $item,
    );

No attributes are required on new. The form's fields will be built from
the form definitions. If no initial data object or defaults have been provided, the form
will be empty. Most attributes can be set on either 'new' or 'process'.
The common attributes to be passed in to the constructor for a database form
are either item\_id and schema or item:

    item_id  - database row primary key
    item     - database row object
    schema   - (for DBIC) the DBIx::Class schema

The following are sometimes passed in, but are also often set
in the form class:

    item_class  - source name of row
    dependency  - (see dependency)
    field_list  - an array of field definitions
    init_object - a hashref or object to provide initial values

Examples of creating a form object with new:

    my $form = MyApp::Form::User->new;

    # database form using a row object
    my $form = MyApp::Form::Member->new( item => $row );

    # a dynamic form (no form class has been defined)
    my $form = HTML::FormHandler::Model::DBIC->new(
        item_id         => $id,
        item_class    => 'User',
        schema          => $schema,
        field_list         => [
                name    => 'Text',
                active  => 'Boolean',
                submit_btn => 'Submit',
        ],
    );

See the model class for more information about 'item', 'item\_id',
'item\_class', and 'schema' (for the DBIC model).
[HTML::FormHandler::Model::DBIC](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AModel%3A%3ADBIC).

FormHandler forms are handled in two steps: 1) create with 'new',
2) handle with 'process'. FormHandler doesn't
care whether most parameters are set on new or process or update,
but a 'field\_list' argument must be passed in on 'new' since the
fields are built at construction time.

If you want to update field attributes on the 'process' call, you can
use an 'update\_field\_list' or 'defaults' hashref attribute , or subclass
update\_fields in your form. The 'update\_field\_list' hashref can be used
to set any field attribute. The 'defaults' hashref will update only
the 'default' attribute in the field. (There are a lot of ways to
set defaults. See [HTML::FormHandler::Manual::Defaults](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ADefaults).)

    $form->process( defaults => { foo => 'foo_def', bar => 'bar_def' } );
    $form->process( update_field_list => { foo => { label => 'New Label' } });

Field results are built on the 'new' call, but will then be re-built
on the process call. If you always use 'process' before rendering the form,
accessing fields, etc, you can set the 'no\_preload' flag to skip this step.

## Processing the form

### process

Call the 'process' method on your form to perform validation and
update. A database form must have either an item (row object) or
a schema, item\_id (row primary key), and item\_class (usually set in the form).
A non-database form requires only parameters.

    $form->process( item => $book, params => $c->req->parameters );
    $form->process( item_id => $item_id,
        schema => $schema, params => $c->req->parameters );
    $form->process( params => $c->req->parameters );

This process method returns the 'validated' flag (`$form->validated`).
If it is a database form and the form validates, the database row
will be updated.

After the form has been processed, you can get a parameter hashref suitable
for using to fill in the form from `$form->fif`.
A hash of inflated values (that would be used to update the database for
a database form) can be retrieved with `$form->value`.

If you don't want to update the database on this process call, you can
set the 'no\_update' flag:

    $form->process( item => $book, params => $params, no_update => 1 );

### params

Parameters are passed in when you call 'process'.
HFH gets data to validate and store in the database from the params hash.
If the params hash is empty, no validation is done, so it is not necessary
to check for POST before calling `$form->process`. (Although see
the 'posted' option for complications.)

Params can either be in the form of CGI/HTTP style params:

    {
       user_name => "Joe Smith",
       occupation => "Programmer",
       'addresses.0.street' => "999 Main Street",
       'addresses.0.city' => "Podunk",
       'addresses.0.country' => "UT",
       'addresses.0.address_id' => "1",
       'addresses.1.street' => "333 Valencia Street",
       'addresses.1.city' => "San Francisco",
       'addresses.1.country' => "UT",
       'addresses.1.address_id' => "2",
    }

or as structured data in the form of hashes and lists:

    {
       addresses => [
          {
             city => 'Middle City',
             country => 'GK',
             address_id => 1,
             street => '101 Main St',
          },
          {
             city => 'DownTown',
             country => 'UT',
             address_id => 2,
             street => '99 Elm St',
          },
       ],
       'occupation' => 'management',
       'user_name' => 'jdoe',
    }

CGI style parameters will be converted to hashes and lists for HFH to
operate on.

### posted

Note that FormHandler by default uses empty params as a signal that the
form has not actually been posted, and so will not attempt to validate
a form with empty params. Most of the time this works OK, but if you
have a small form with only the controls that do not return a post
parameter if unselected (checkboxes and select lists), then the form
will not be validated if everything is unselected. For this case you
can either add a hidden field as an 'indicator', or use the 'posted' flag:

    $form->process( posted => ($c->req->method eq 'POST'), params => ... );

The 'posted' flag also works to prevent validation from being performed
if there are extra params in the params hash and it is not a 'POST' request.

## Getting data out

### fif  (fill in form)

If you don't use FormHandler rendering and want to fill your form values in
using some other method (such as with HTML::FillInForm or using a template)
this returns a hash of values that are equivalent to params which you may
use to fill in your form.

The fif value for a 'title' field in a TT form:

    [% form.fif.title %]

Or you can use the 'fif' method on individual fields:

    [% form.field('title').fif %]

If you use FormHandler to render your forms or field you probably won't use
these methods.

### value

Returns a hashref of all field values. Useful for non-database forms, or if
you want to update the database yourself. The 'fif' method returns
a hashref with the field names for the keys and the field's 'fif' for the
values; 'value' returns a hashref with the field accessors for the keys, and the
field's 'value' (possibly inflated) for the values.

Forms containing arrays to be processed with [HTML::FormHandler::Field::Repeatable](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AField%3A%3ARepeatable)
will have parameters with dots and numbers, like 'addresses.0.city', while the
values hash will transform the fields with numbers to arrays.

## Accessing and setting up fields

Fields are declared with a number of attributes which are defined in
[HTML::FormHandler::Field](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AField). If you want additional attributes you can
define your own field classes (or apply a role to a field class - see
[HTML::FormHandler::Manual::Cookbook](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ACookbook)). The field 'type' (used in field
definitions) is the short class name of the field class, used when
searching the 'field\_name\_space' for the field class.

### has\_field

The most common way of declaring fields is the 'has\_field' syntax.
Using the 'has\_field' syntax sugar requires ` use HTML::FormHandler::Moose; `
or ` use HTML::FormHandler::Moose::Role; ` in a role.
See [HTML::FormHandler::Manual::Intro](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AIntro)

    use HTML::FormHandler::Moose;
    has_field 'field_name' => ( type => 'FieldClass', .... );

### field\_list

A 'field\_list' is an array of field definitions which can be used as an
alternative to 'has\_field' in small, dynamic forms to create fields.

    field_list => [
       field_one => {
          type => 'Text',
          required => 1
       },
       field_two => 'Text,
    ]

The field\_list array takes elements which are either a field\_name key
pointing to a 'type' string or a field\_name key pointing to a
hashref of field attributes. You can also provide an array of
hashref elements with the name as an additional attribute.
The field list can be set inside a form class, when you want to
add fields to the form depending on some other state, although
you can also create all the fields and set some of them inactive.

    sub field_list {
       my $self = shift;
       my $fields = $self->schema->resultset('SomeTable')->
                           search({user_id => $self->user_id, .... });
       my @field_list;
       while ( my $field = $fields->next )
       {
          < create field list >
       }
       return \@field_list;
    }

### update\_field\_list

Used to dynamically set particular field attributes on the 'process' (or
'run') call. (Will not create fields.)

    $form->process( update_field_list => {
       foo_date => { format => '%m/%e/%Y', date_start => '10-01-01' } },
       params => $params );

The 'update\_field\_list' is processed by the 'update\_fields' form method,
which can also be used in a form to do specific field updates:

    sub update_fields {
        my $self = shift;
        $self->field('foo')->temp( 'foo_temp' );
        $self->field('bar')->default( 'foo_value' );
        $self->next::method();
    }

(Note that you although you can set a field's 'default', you can't set a
field's 'value' directly here, since it will
be overwritten by the validation process. Set the value in a field
validation method.)

### update\_subfields

Yet another way to provide settings for the field, except this one is intended for
use in roles and compound fields, and is only executed when the form is
initially built. It takes the same field name keys as 'update\_field\_list', plus
'all', 'by\_flag', and 'by\_type'.

    sub build_update_subfields {{
        all => { tags => { wrapper_tag => 'p' } },
        foo => { element_class => 'blue' },
    }}

The 'all' hash key will apply updates to all fields. (Conflicting attributes
in a field definition take precedence.)

The 'by\_flag' hash key will apply updates to fields with a particular flag.
The currently supported subkeys are 'compound', 'contains', and 'repeatable'.
(For repeatable instances, in addition to 'contains' you can also use the
'repeatable' key and the 'init\_contains' attribute.)
This is useful for turning on the rendering
wrappers for compounds and repeatables, which are off by default. (The
repeatable instances are wrapped by default.)

    sub build_update_subfields {{
        by_flag => { compound => { do_wrapper => 1 } },
        by_type => { Select => { element_class => ['sel_elem'] } },
    }}

The 'by\_type' hash key will provide values to all fields of a particular
type.

### defaults

This is a more specialized version of the 'update\_field\_list'. It can be
used to provide 'default' settings for fields, in a shorthand way (you don't
have to say 'default' for every field).

    $form->process( defaults => { foo => 'this_foo', bar => 'this_bar' }, ... );

### active/inactive

A field can be marked 'inactive' and set to active at new or process time
by specifying the field name in the 'active' array:

    has_field 'foo' => ( type => 'Text', inactive => 1 );
    ...
    my $form = MyApp::Form->new( active => ['foo'] );
    ...
    $form->process( active => ['foo'] );

Or a field can be a normal active field and set to inactive at new or process
time:

    has_field 'bar';
    ...
    my $form = MyApp::Form->new( inactive => ['foo'] );
    ...
    $form->process( inactive => ['foo'] );

Fields specified as active/inactive on new will have the form's inactive/active
arrayref cleared and the field's inactive flag set appropriately, so that
the state will be effective for the life of the form object. Fields specified as
active/inactive on 'process' will have the field's '\_active' flag set for the life
of the request (the \_active flag will be cleared when the form is cleared).

The 'sorted\_fields' method returns only active fields, sorted according to the
'order' attribute. The 'fields' method returns all fields.

    foreach my $field ( $self->sorted_fields ) { ... }

You can test whether a field is active by using the field 'is\_active' and 'is\_inactive'
methods.

### field\_name\_space

Use to look for field during form construction. If a field is not found
with the field\_name\_space (or HTML::FormHandler/HTML::FormHandlerX),
the 'type' must start with a '+' and be the complete package name.

### fields

The array of fields, objects of [HTML::FormHandler::Field](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AField) or its subclasses.
A compound field will itself have an array of fields,
so this is a tree structure.

### sorted\_fields

Returns those fields from the fields array which are currently active. This
is the method that returns the fields that are looped through when rendering.

### field($name), subfield($name)

'field' is the method that is usually called to access a field:

    my $title = $form->field('title')->value;
    [% f = form.field('title') %]

    my $city = $form->field('addresses.0.city')->value;

Pass a second true value to die on errors.

Since fields are searched for using the form as a base, if you want to find
a sub field in a compound field method, the 'subfield' method may be more
useful, since you can search starting at the current field. The 'chained'
method also works:

    -- in a compound field --
    $self->field('media.caption'); # fails
    $self->field('media')->field('caption'); # works
    $self->subfield('media.caption'); # works

## Constraints and validation

Most validation is performed on a per-field basis, and there are a number
of different places in which validation can be performed.

See also [HTML::FormHandler::Manual::Validation](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AValidation).

### Form class validation for individual fields

You can define a method in your form class to perform validation on a field.
This method is the equivalent of the field class validate method except it is
in the form class, so you might use this
validation method if you don't want to create a field subclass.

It has access to the form ($self) and the field.
This method is called after the field class 'validate' method, and is not
called if the value for the field is empty ('', undef). (If you want an
error message when the field is empty, use the 'required' flag and message
or the form 'validate' method.)
The name of this method can be set with 'set\_validate' on the field. The
default is 'validate\_' plus the field name:

    sub validate_testfield { my ( $self, $field ) = @_; ... }

If the field name has dots they should be replaced with underscores.

Note that you can also provide a coderef which will be a method on the field:

    has_field 'foo' => ( validate_method => \&validate_foo );

### validate

This is a form method that is useful for cross checking values after they have
been saved as their final validated value, and for performing more complex
dependency validation. It is called after all other field validation is done,
and whether or not validation has succeeded, so it has access to the
post-validation values of all the fields.

This is the best place to do validation checks that depend on the values of
more than one field.

## Accessing errors

Also see [HTML::FormHandler::Manual::Errors](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AErrors).

Set an error in a field with `$field->add_error('some error string');`.
Set a form error not tied to a specific field with
`$self->add_form_error('another error string');`.
The 'add\_error' and 'add\_form\_error' methods call localization. If you
want to skip localization for a particular error, you can use 'push\_errors'
or 'push\_form\_errors' instead.

    has_errors - returns true or false
    error_fields - returns list of fields with errors
    errors - returns array of error messages for the entire form
    num_errors - number of errors in form

Each field has an array of error messages. (errors, has\_errors, num\_errors,
clear\_errors)

    $form->field('title')->errors;

Compound fields also have an array of error\_fields.

## Clear form state

The clear method is called at the beginning of 'process' if the form
object is reused, such as when it is persistent in a Moose attribute,
or in tests.  If you add other attributes to your form that are set on
each request, you may need to clear those yourself.

If you do not call the form's 'process' method on a persistent form,
such as in a REST controller's non-POST method, or if you only call
process when the form is posted, you will also need to call `$form->clear`.

The 'run' method which returns a result object always performs 'clear', to
keep the form object clean.

## Miscellaneous attributes

### name

The form's name.  Useful for multiple forms. Used for the form element 'id'.
When 'html\_prefix' is set it is used to construct the field 'id'
and 'name'.  The default is "form" + a one to three digit random number.
Because the HTML standards have flip-flopped on whether the HTML
form element can contain a 'name' attribute, please set a name attribute
using 'form\_element\_attr'.

### init\_object

An 'init\_object' may be used instead of the 'item' to pre-populate the values
in the form. This can be useful when populating a form from default values
stored in a similar but different object than the one the form is creating.
The 'init\_object' should be either a hash or the same type of object that
the model uses (a DBIx::Class row for the DBIC model). It can be set in a
variety of ways:

    my $form = MyApp::Form->new( init_object => { .... } );
    $form->process( init_object => {...}, ... );
    has '+init_object' => ( default => sub { { .... } } );
    sub init_object { my $self = shift; .... }

The method version is useful if the organization of data in your form does
not map to an existing or database object in an automatic way, and you need
to create a different type of object for initialization. (You might also
want to do 'update\_model' yourself.)

Also see the 'use\_init\_obj\_over\_item' and the 'use\_init\_obj\_when\_no\_accessor\_in\_item'
flags, if you want to provide both an item and an init\_object, and use the
values from the init\_object.

The 'use\_init\_obj\_when\_no\_accessor\_in\_item' flag is particularly useful
when some of the fields in your form come from the database and some
are process or environment type flags that are not in the database. You
can provide defaults from both a database row and an 'init\_object.

### ctx

Place to store application context for your use in your form's methods.

### language\_handle

See 'language\_handle' and '\_build\_language\_handle' in
[HTML::FormHandler::TraitFor::I18N](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3ATraitFor%3A%3AI18N).

### dependency

Arrayref of arrayrefs of fields. If one of a group of fields has a
value, then all of the group are set to 'required'.

    has '+dependency' => ( default => sub { [
       ['street', 'city', 'state', 'zip' ],] }
    );

## Flags

### validated, is\_valid

Flag that indicates if form has been validated. You might want to use
this flag if you're doing something in between process and returning,
such as setting a stash key. ('is\_valid' is a synonym for this flag)

    $form->process( ... );
    $c->stash->{...} = ...;
    return unless $form->validated;

### ran\_validation

Flag to indicate that validation has been run. This flag will be
false when the form is initially loaded and displayed, since
validation is not run until FormHandler has params to validate.

### verbose, dump, peek

Flag to dump diagnostic information. See 'dump\_fields' and
'dump\_validated'. 'Peek' can be useful in diagnosing bugs.
It will dump a brief listing of the fields and results.

    $form->process( ... );
    $form->peek;

### html\_prefix

Flag to indicate that the form name is used as a prefix for fields
in an HTML form. Useful for multiple forms
on the same HTML page. The prefix is stripped off of the fields
before creating the internal field name, and added back in when
returning a parameter hash from the 'fif' method. For example,
the field name in the HTML form could be "book.borrower", and
the field name in the FormHandler form (and the database column)
would be just "borrower".

    has '+name' => ( default => 'book' );
    has '+html_prefix' => ( default => 1 );

Also see the Field attribute "html\_name", a convenience function which
will return the form name + "." + field full\_name

### is\_html5

Flag to indicate the fields will render using specialized attributes for html5.
Set to 0 by default.

### use\_defaults\_over\_obj

The 'normal' precedence is that if there is an accessor in the item/init\_object
that value is used and not the 'default'. This flag makes the defaults of higher
precedence. Mainly useful if providing an empty row on create.

### use\_init\_obj\_over\_item

If you are providing both an item and an init\_object, and want the init\_object
to be used for defaults instead of the item.

## For use in HTML

    form_element_attr - hashref for setting arbitrary HTML attributes
       set in form with: sub build_form_element_attr {...}
    form_element_class - arrayref for setting form tag class
    form_wrapper_attr - hashref for form wrapper element attributes
       set in form with: sub build_form_wrapper_attr {...}
    form_wrapper_class - arrayref for setting wrapper class
    do_form_wrapper - flag to wrap the form
    http_method - For storing 'post' or 'get'
    action - Store the form 'action' on submission. No default value.
    uuid - generates a string containing an HTML field with UUID
    form_tags - hashref of tags for use in rendering code
    widget_tags - rendering tags to be transferred to fields

Discouraged (use form\_element\_attr instead):

    style - adds a 'style' attribute to the form tag
    enctype - Request enctype

Note that the form tag contains an 'id' attribute which is set to the
form name. The standards have been flip-flopping over whether a 'name'
attribute is valid. It can be set with 'form\_element\_attr'.

The rendering of the HTML attributes is done using the 'process\_attrs'
function and the 'element\_attributes' or 'wrapper\_attributes' method,
which adds other attributes in for backward compatibility, and calls
the 'html\_attributes' hook.

For HTML attributes, there is a form method hook, 'html\_attributes',
which can be used to customize/modify/localize form & field HTML attributes.
Types: element, wrapper, label, form\_element, form\_wrapper, checkbox\_label

    sub html_attributes {
        my ( $self, $obj, $type, $attrs, $result ) = @_;

        # obj is either form or field
        $attr->{class} = 'label' if $type eq 'label';
        $attr->{placeholder} = $self->_localize($attr->{placeholder})
            if exists $attr->{placeholder};
        return $attr;
    }

Also see the documentation in [HTML::FormHandler::Field](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AField) and in
[HTML::FormHandler::Manual::Rendering](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ARendering).

# SUPPORT

IRC:

    Join #formhandler on irc.perl.org

Mailing list:

    http://groups.google.com/group/formhandler

Code repository:

    http://github.com/gshank/html-formhandler/tree/master

Bug tracker:

    https://rt.cpan.org/Dist/Display.html?Name=HTML-FormHandler

# SEE ALSO

[HTML::FormHandler::Manual](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual)

[HTML::FormHandler::Manual::Tutorial](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ATutorial)

[HTML::FormHandler::Manual::Intro](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AIntro)

[HTML::FormHandler::Manual::Templates](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ATemplates)

[HTML::FormHandler::Manual::Cookbook](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ACookbook)

[HTML::FormHandler::Manual::Rendering](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3ARendering)

[HTML::FormHandler::Manual::Reference](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AManual%3A%3AReference)

[HTML::FormHandler::Field](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AField)

[HTML::FormHandler::Model::DBIC](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AModel%3A%3ADBIC)

[HTML::FormHandler::Render::Simple](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3ARender%3A%3ASimple)

[HTML::FormHandler::Render::Table](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3ARender%3A%3ATable)

[HTML::FormHandler::Moose](https://metacpan.org/pod/HTML%3A%3AFormHandler%3A%3AMoose)

# CONTRIBUTORS

gshank: Gerda Shank <gshank@cpan.org>

zby: Zbigniew Lukasiak <zby@cpan.org>

t0m: Tomas Doran <bobtfish@bobtfish.net>

augensalat: Bernhard Graf <augensalat@gmail.com>

cubuanic: Oleg Kostyuk <cub.uanic@gmail.com>

rafl: Florian Ragwitz <rafl@debian.org>

mazpe: Lester Ariel Mesa

dew: Dan Thomas

koki: Klaus Ita

jnapiorkowski: John Napiorkowski

lestrrat: Daisuke Maki

hobbs: Andrew Rodland

Andy Clayton

boghead: Bryan Beeley

Csaba Hetenyi

Eisuke Oishi

Lian Wan Situ

Murray

Nick Logan

Vladimir Timofeev

diegok: Diego Kuperman

ijw: Ian Wells

amiri: Amiri Barksdale

ozum: Ozum Eldogan

lukast: Lukas Thiemeier

Initially based on the source code of [Form::Processor](https://metacpan.org/pod/Form%3A%3AProcessor) by Bill Moseley
