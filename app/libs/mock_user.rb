# for now ; authenticatication has not yet been decided ; just mock it
module MockUser
  Visitor = nil #
  Student = Student.new(id: SecureRandom.hex,
                        first_name: 'Fatou',
                        last_name: 'F',
                        email: 'fatou@ent.fr',
                        school: School.where(postal_code: 75019).first)
  Employer = Employer.new(id: SecureRandom.hex,
                          first_name: 'Madame',
                          last_name: 'Accor',
                          email: 'madameaccor@fakeaccor.fr')
  SchoolManager = SchoolManager.new(id: SecureRandom.hex,
                                    first_name: 'Fred',
                                    last_name: 'Fred',
                                    email: 'fred@ac-ent.fr',
                                    school: School.where(postal_code: 75019).first)
end
