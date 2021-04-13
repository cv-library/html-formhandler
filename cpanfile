requires 'Carp',                         '0';
requires 'Class::Load',                  '0.06';
requires 'Data::Clone',                  '0';
requires 'DateTime',                     '0';
requires 'DateTime::Format::Strptime',   '0';
requires 'Email::Valid',                 '0';
requires 'File::ShareDir',               '0';
requires 'File::Spec',                   '0';
requires 'HTML::Entities',               '0';
requires 'HTML::TreeBuilder',            '3.23';
requires 'JSON::MaybeXS',                '1.003003';
requires 'List::Util',                   '1.33';
requires 'Locale::Maketext',             '1.09';
requires 'Moose',                        '2.1403'; # raised Moose prereq because 2.0604 fails
requires 'MooseX::Types',                '0.20';
requires 'MooseX::Types::Common',        '0';
requires 'MooseX::Types::LoadableClass', '0.006';
requires 'Sub::Exporter',                '0';
requires 'Sub::Util',                    '1.40'; # set_subname
requires 'Try::Tiny',                    '0';
requires 'namespace::autoclean',         '0.09';

on runtime => sub {
    recommends 'Crypt::Blowfish',        '0';
    recommends 'Crypt::CBC',             '3.00';
    recommends 'GD::SecurityImage',      '0';
    recommends 'MIME::Base64',           '0';
};

on test => sub {
    requires 'PadWalker',                '0';
    requires 'Test::Differences',        '0';
    requires 'Test::Exception',          '0';
    requires 'Test::Memory::Cycle',      '1.04';
    requires 'Test::More',               '0.94';
    requires 'Test::Needs',              '0';
    requires 'Test::Warn',               '0';
};
