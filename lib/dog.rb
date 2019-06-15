class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed) VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE dogs.id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_or_create_by(name:, breed:)  
        array_rows = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !array_rows.empty?
            dog = self.new_from_db(array_rows[0])
        else
            dog = Dog.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        dog_inst = self.new_from_db(dog_row)
        dog_inst
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end