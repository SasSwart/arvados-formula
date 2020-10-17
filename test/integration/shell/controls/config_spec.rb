# frozen_string_literal: true

siab_stanza = <<~SIAB_STANZA
  SHELLINABOX_PORT=4200
  # SSL is disabled because it is terminated in Nginx. Adjust as needed.
  SHELLINABOX_ARGS="--disable-ssl --no-beep --service=/shell.fixme.example.net:AUTH:HOME:SHELL"
SIAB_STANZA

libpam_stanza = <<~LIBPAM_STANZA
  auth [success=1 default=ignore] /usr/lib/pam_arvados.so fixme.example.net shell.fixme.example.net
LIBPAM_STANZA

control 'shellinabox configuration' do
  title 'should match desired lines'

  describe file('/etc/default/shellinabox') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') do
      should include(
        # rubocop:disable Layout/LineLength
        'File managed by Salt at <salt://arvados/shell/config/files/default/shell-shellinabox.tmpl.jinja>.'
        # rubocop:enable Layout/LineLength
      )
    end
    its('content') { should include(siab_stanza) }
  end
end

control 'libpam-arvados configuration' do
  title 'should match desired lines'

  describe file('/etc/pam.d/arvados') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('content') do
      should include(
        # rubocop:disable Layout/LineLength
        'File managed by Salt at <salt://arvados/shell/config/files/default/shell-libpam-arvados.tmpl.jinja>.'
        # rubocop:enable Layout/LineLength
      )
    end
    its('content') { should include(libpam_stanza) }
  end
end
