# for now ; authenticatication has not yet been decided ; just mock it
module User
  module Roles
    Visitor = 'visitor'
    Student = 'student'
    Employer = 'employer'
  end

  User = Struct.new(:id, :role, keyword_init: true) do
    def visitor?; self.role == Roles::Visitor; end
    def student?; self.role == Roles::Student; end
    def employer?; self.role == Roles::Employer; end
  end

  Visitor = User.new(id: SecureRandom.hex, role: Roles::Visitor)
  Student = User.new(id: SecureRandom.hex, role: Roles::Student)
  Employer = User.new(id: SecureRandom.hex, role: Roles::Employer)
end
