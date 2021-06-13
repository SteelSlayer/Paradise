import { useBackend } from "../backend";
import { Button, Section, Box, Flex, Icon, Collapsible, Dimmer } from "../components";
import { Window } from "../layouts";

export const Biogenerator = (props, context) => {
  const { data } = useBackend(context);
  const { container } = data;
  return (
    <Window resizable>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        {!container ? (
          <MissingContainer />
        ) : (
          <>
            <Processing />
            <Biomass />
            <Controls />
            <Products />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const MissingContainer = (props, context) => {
  return (
    <Section flexGrow="1">
      <Flex height="100%">
        <Flex.Item
          grow="1"
          textAlign="center"
          align="center"
          color="silver">
          <Icon
            name="flask"
            size="5"
            mb={3}
          /><br />
          The biogenerator is missing a container.
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Processing = (props, context) => {
  const { data } = useBackend(context);
  const { processing } = data;
  if (processing) {
    return (
      <Dimmer>
        <Flex>
          <Flex.Item
            bold
            textColor="silver"
            textAlign="center"
            mb={2}>
            <Icon
              name="spinner"
              spin={1}
              size={4}
              mb={4}
            /><br />
            The biogenerator is processing...
          </Flex.Item>
        </Flex>
      </Dimmer>
    );
  }
};

const Biomass = (props, context) => {
  const { data } = useBackend(context);
  const { biomass } = data;
  return (
    <Section title="Biomass">
      <Box color="silver">
        {biomass} units
      </Box>
    </Section>
  );
};

const Controls = (props, context) => {
  const { act, data } = useBackend(context);
  const { stored_items } = data;
  return (
    <Section title="Controls">
      <Flex>
        <Flex.Item
          mr={0.8}
          width="50%">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={stored_items <= 0}
            content="Activate"
            onClick={() => act('activate')}
          />
        </Flex.Item>
        <Flex.Item width="50%">
          <Button
            fluid
            textAlign="center"
            icon="eject"
            content="Detach container"
            onClick={() => act('detach')}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Products = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    designs,
    display_categories,
    efficiency,
  } = data;
  return (
    <Section
      title="Products"
      flexGrow="1">
      {display_categories.map((category, i) => (
        <Collapsible
          open
          key={i}
          title={category}>
          {designs.filter(d => d.category === category).map((design, _i) => (
            <Flex
              key={_i}
              mt={0.4}
              color="silver"
              className="candystripe"
              align="center">
              <Flex.Item width="45%" ml={0.5}>
                {design.name}
              </Flex.Item>
              <Flex.Item width="25.6%">
                {design.cost}
              </Flex.Item>
              <Flex.Item>
                <Button
                  mr={0.5}
                  disabled={biomass < design.cost / efficiency}
                  content="1x"
                  onClick={() => act('create', {
                    design_id: design.id,
                    amount: 1,
                  })}
                />
                <Button
                  mr={0.5}
                  disabled={biomass < design.cost / efficiency * 5}
                  content="5x"
                  onClick={() => act('create', {
                    design_id: design.id,
                    amount: 1,
                  })}
                />
                <Button
                  disabled={biomass < design.cost / efficiency * 10}
                  content="10x"
                  onClick={() => act('create', {
                    design_id: design.id,
                    amount: 1,
                  })}
                />
              </Flex.Item>
            </Flex>
          ))}
        </Collapsible>
      ))}
    </Section>
  );
};
