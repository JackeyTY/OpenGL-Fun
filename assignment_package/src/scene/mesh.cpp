#include "mesh.h"
#include <tinyobj/tiny_obj_loader.h>
#include <iostream>
#include <QFile>

Mesh::Mesh(OpenGLContext *context)
    : Drawable(context),
      mp_texture(nullptr), mp_bgTexture(nullptr)
{}

void Mesh::createCube(const char *textureFile, const char *bgTextureFile)
{
    // Code that sets up texture data on the GPU
    mp_texture = std::unique_ptr<Texture>(new Texture(context));
    mp_texture->create(textureFile);

    mp_bgTexture = std::unique_ptr<Texture>(new Texture(context));
    mp_bgTexture->create(bgTextureFile);

    // TODO: Create VBO data for positions, normals, UVs, and indices

    std::vector<glm::vec4> posBank {glm::vec4(-1, 1, 1, 1),
                                    glm::vec4(-1, -1, 1, 1),
                                    glm::vec4(1, -1, 1, 1),
                                    glm::vec4(1, 1, 1, 1),
                                    glm::vec4(-1, 1, -1, 1),
                                    glm::vec4(-1, -1, -1, 1),
                                    glm::vec4(1, -1, -1, 1),
                                    glm::vec4(1, 1, -1, 1)};

    std::vector<glm::vec4> norBank {glm::vec4(0, 0, 1, 0),
                                    glm::vec4(-1, 0, 0, 0),
                                    glm::vec4(0, 1, 0, 0),
                                    glm::vec4(1, 0, 0, 0),
                                    glm::vec4(0, 0, -1, 0),
                                    glm::vec4(0, -1, 0, 0)};

    std::vector<glm::vec2> uvBank {glm::vec2(0, 1),
                                   glm::vec2(0, 0),
                                   glm::vec2(1, 0),
                                   glm::vec2(1, 1)};

    std::vector<glm::vec4> pos {posBank[0], posBank[1], posBank[2], posBank[3],
                                posBank[0], posBank[3], posBank[4], posBank[7],
                                posBank[0], posBank[1], posBank[4], posBank[5],
                                posBank[4], posBank[5], posBank[6], posBank[7],
                                posBank[1], posBank[2], posBank[5], posBank[6],
                                posBank[2], posBank[3], posBank[6], posBank[7]};

    std::vector<glm::vec4> nor {norBank[0], norBank[0], norBank[0], norBank[0],
                                norBank[2], norBank[2], norBank[2], norBank[2],
                                norBank[1], norBank[1], norBank[1], norBank[1],
                                norBank[4], norBank[4], norBank[4], norBank[4],
                                norBank[5], norBank[5], norBank[5], norBank[5],
                                norBank[3], norBank[3], norBank[3], norBank[3]};

    std::vector<glm::vec2> uvs {uvBank[0], uvBank[1], uvBank[2], uvBank[3],
                                uvBank[0], uvBank[3], uvBank[1], uvBank[2],
                                uvBank[0], uvBank[1], uvBank[3], uvBank[2],
                                uvBank[1], uvBank[0], uvBank[3], uvBank[2],
                                uvBank[1], uvBank[2], uvBank[0], uvBank[3],
                                uvBank[2], uvBank[3], uvBank[1], uvBank[0]};

    std::vector<GLuint> idx {0, 1, 2, 0, 2, 3,
                             4, 5, 6, 5, 6, 7,
                             8, 9, 10, 9, 10, 11,
                             12, 13, 14, 12, 14, 15,
                             16, 17, 18, 17, 18, 19,
                             20, 21, 22, 21, 22, 23};

    count = 36; // TODO: Set "count" to the number of indices in your index VBO

    generateIdx();
    context->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufIdx);
    context->glBufferData(GL_ELEMENT_ARRAY_BUFFER, idx.size() * sizeof(GLuint), idx.data(), GL_STATIC_DRAW);

    generatePos();
    context->glBindBuffer(GL_ARRAY_BUFFER, bufPos);
    context->glBufferData(GL_ARRAY_BUFFER, pos.size() * sizeof(glm::vec4), pos.data(), GL_STATIC_DRAW);

    generateNor();
    context->glBindBuffer(GL_ARRAY_BUFFER, bufNor);
    context->glBufferData(GL_ARRAY_BUFFER, nor.size() * sizeof(glm::vec4), nor.data(), GL_STATIC_DRAW);

    generateUV();
    context->glBindBuffer(GL_ARRAY_BUFFER, bufUV);
    context->glBufferData(GL_ARRAY_BUFFER, uvs.size() * sizeof(glm::vec2), uvs.data(), GL_STATIC_DRAW);
}

void Mesh::create()
{
    // Does nothing, as we have two separate VBO data
    // creation functions: createFromOBJ, which creates
    // our mesh VBOs from OBJ file data, and createCube,
    // which you will implement.
}

void Mesh::bindTexture() const
{
    mp_texture->bind(0);
}

void Mesh::loadTexture() const
{
    mp_texture->load(0);
}


void Mesh::bindBGTexture() const
{
    mp_bgTexture->bind(2);
}

void Mesh::loadBGTexture() const
{
    mp_bgTexture->load(2);
}

void Mesh::createFromOBJ(const char* filename, const char *textureFile, const char *bgTextureFile)
{
    std::vector<tinyobj::shape_t> shapes; std::vector<tinyobj::material_t> materials;
    std::string errors = tinyobj::QLoadObj(shapes, materials, filename);
    std::cout << errors << std::endl;
    if(errors.size() == 0)
    {
        count = 0;
        //Read the information from the vector of shape_ts
        for(unsigned int i = 0; i < shapes.size(); i++)
        {
            std::vector<float> &positions = shapes[i].mesh.positions;
            std::vector<float> &normals = shapes[i].mesh.normals;
            std::vector<float> &uvs = shapes[i].mesh.texcoords;
            std::vector<unsigned int> &indices = shapes[i].mesh.indices;

            bool normalsExist = normals.size() > 0;
            bool uvsExist = uvs.size() > 0;


            std::vector<GLuint> glIndices;
            for(unsigned int ui : indices)
            {
                glIndices.push_back(ui);
            }
            std::vector<glm::vec4> glPos;
            std::vector<glm::vec4> glNor;
            std::vector<glm::vec2> glUV;

            for(int x = 0; x < positions.size(); x += 3)
            {
                glPos.push_back(glm::vec4(positions[x], positions[x + 1], positions[x + 2], 1.f));
                if(normalsExist)
                {
                    glNor.push_back(glm::vec4(normals[x], normals[x + 1], normals[x + 2], 1.f));
                }
            }

            if(uvsExist)
            {
                for(int x = 0; x < uvs.size(); x += 2)
                {
                    glUV.push_back(glm::vec2(uvs[x], uvs[x + 1]));
                }
            }

            generateIdx();
            context->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufIdx);
            context->glBufferData(GL_ELEMENT_ARRAY_BUFFER, glIndices.size() * sizeof(GLuint), glIndices.data(), GL_STATIC_DRAW);

            generatePos();
            context->glBindBuffer(GL_ARRAY_BUFFER, bufPos);
            context->glBufferData(GL_ARRAY_BUFFER, glPos.size() * sizeof(glm::vec4), glPos.data(), GL_STATIC_DRAW);

            if(normalsExist)
            {
                generateNor();
                context->glBindBuffer(GL_ARRAY_BUFFER, bufNor);
                context->glBufferData(GL_ARRAY_BUFFER, glNor.size() * sizeof(glm::vec4), glNor.data(), GL_STATIC_DRAW);
            }

            if(uvsExist)
            {
                generateUV();
                context->glBindBuffer(GL_ARRAY_BUFFER, bufUV);
                context->glBufferData(GL_ARRAY_BUFFER, glUV.size() * sizeof(glm::vec2), glUV.data(), GL_STATIC_DRAW);
            }

            count += indices.size();
        }
    }
    else
    {
        //An error loading the OBJ occurred!
        std::cout << errors << std::endl;
    }

    mp_texture = std::unique_ptr<Texture>(new Texture(context));
    mp_texture->create(textureFile);

    mp_bgTexture = std::unique_ptr<Texture>(new Texture(context));
    mp_bgTexture->create(bgTextureFile);
}
