# frozen_string_literal: true

control 'mariadb.package.install' do
  title 'The required package should be installed'

  package_name = 'mariadb-server'

  describe package(package_name) do
    it { should be_installed }
  end
end
