# frozen_string_literal: true

workbench2_service = <<-WORKBENCH2_STANZA
      Workbench2:
        ExternalURL: "https://workbench2.example.net"
WORKBENCH2_STANZA

control 'arvados configuration' do
  title 'should match desired workbench2 lines'

  describe file('/etc/arvados/config.yml') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'www-data' }
    its('mode') { should cmp '0640' }
    its('content') do
      should include(
        'File managed by Salt at <salt://arvados/files/default/config.tmpl.jinja>.'
      )
    end
    its('content') { should include(workbench2_service) }
  end
end
