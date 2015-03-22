require 'pry'

class Recipe
  def initialize(name, id, instructions, description, ingredients = [])
    @name = name
    @id = id
    @instructions = instructions
    @description = description
    @ingredients = ingredients
  end

  def self.db_connection
  	connection = PG.connect(dbname: "recipes")
  	yield(connection)
  	ensure
    	connection.close
  end

  def self.find(id_params)
    recipe_data = ""
    ingredient_data = []
      recipe_data = db_connection {|conn| conn.exec_params("SELECT recipes.id AS id, recipes.name AS name, recipes.instructions,
        recipes.description, ingredients.name AS ing_name, ingredients.id AS ing_id FROM recipes JOIN ingredients ON ingredients.recipe_id = recipes.id
        WHERE recipes.id = $1", [id_params])}

      recipe_data.each do |recipe|
        ingredient_data << Ingredient.new(recipe["ing_name"], recipe["ing_id"])
      end
      Recipe.new(recipe_data.first["name"], recipe_data.first["id"], recipe_data.first["instructions"], recipe_data.first["description"], ingredient_data)
  end

  def self.all
    recipe_list = []
      db_connection {|conn| conn.exec("SELECT * FROM recipes")}.map do |row|
        recipe_list << Recipe.new(row["name"], row["id"], row["instructions"] , row["description"])
      end
    recipe_list
  end

  def id
    @id
  end

  def name
    @name
  end

  def instructions
    @instructions
  end

  def description
    @description
  end

  def ingredients
    @ingredients
  end
end
