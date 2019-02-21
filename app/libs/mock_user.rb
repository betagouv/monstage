# for now ; authenticatication has not yet been decided ; just mock it
module MockUser
  module Roles
    Visitor = 'visitor'
    Student = 'student'
    Employer = 'employer'
  end

  MockUser = Struct.new(:id, :role, keyword_init: true) do
    def visitor?; self.role == Roles::Visitor; end
    def student?; self.role == Roles::Student; end
    def employer?; self.role == Roles::Employer; end
  end

  Visitor = MockUser.new(id: SecureRandom.hex, role: Roles::Visitor)
  Student = MockUser.new(id: SecureRandom.hex, role: Roles::Student)
  Employer = MockUser.new(id: SecureRandom.hex, role: Roles::Employer)
end
